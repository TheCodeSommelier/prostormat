# frozen_string_literal: true

# PlacesController manages actions related to Place resources including listing all places,
# showing details for a single place, creating new places, editing existing places, and
# deleting places. It responds to routes defined in config/routes.rb for the Place model.
class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show new update toggle_primary] # Skip authentication for index
  before_action :set_place, only: %i[edit toggle_primary]

  # Lists and caches all visible places.
  def index
    @places  = Rails.cache.fetch('places/index', expires_in: 1.hour) { Place.visible }
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }

    policy_scope(@places)
    # Apply filters
    if params[:filters].present?
      filter_ids = params[:filters].reject(&:empty?).map(&:to_i)
      if filter_ids.any?
        @places = @places.joins(:place_filters).where(place_filters: { filter_id: filter_ids }).distinct
      end
    end

    # Search by address or city
    @places = @places.search_by_query(params[:query]) if params[:query].present?

    # Filter by capacity 'from' and 'to'
    if params[:min_capacity].present?
      @places = @places.where('max_capacity >= ?', params[:min_capacity])
    end

    @places = @places.order(primary: :desc)

    @places = @places.page(params[:page]).per(6)

    respond_to do |format|
      format.html # For regular HTML requests
      format.json do
        render json: { html: render_to_string(partial: 'shared/places_card_grid', locals: { places: @places },
                                              formats: [:html]) }
      end
    end
  end

  # Shows details for a single place identified by id.
  def show
    @place = Rails.cache.fetch("place_#{params[:id]}") { Place.find(params[:id].to_i) }
    authorize @place

    # This encodes the address into a url for google maps api
    @place_encoded_address = Rails.cache.fetch("place_#{params[:id]}_address") do
      CGI.escape("#{@place.street} #{@place.house_number}, #{@place.postal_code}, #{@place.city}")
    end

    @order = Order.new
    @order.build_bokee

    filter_ids     = @place.filters.pluck(:id)
    base_city_name = @place.city.split(' ').first
    cache_key      = ['related_places', @place.id, filter_ids.sort.join('-'), base_city_name, Place.maximum(:updated_at)]
    # Caches a SQL query to retrieve places related to the show page place by filters, city.
    # Primary places are prioritised. Also this section is limited to two places
    @places = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Place.related_places(@place, filter_ids, base_city_name).to_a
    end
  end

  # Renders a form for creating a new place.
  def new
    @place   = Place.new
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }
    authorize @place
  end

  def create
    filter_ids             = place_params[:filter_ids].map(&:to_i) unless place_params[:filter_ids].nil?
    @place                 = Place.new(place_params.except(:photos))
    filtered_photos_params = place_params[:photos].reject(&:blank?)
    authorize @place

    @place.user = current_user
    @place.hidden = false if current_user.admin?
    p "🔥 place #{@place.id}"

    if check_photo_sizes? && @place.save
      if filter_ids.present?
        place_filters_attributes = filter_ids.map do |filter_id|
          { place_id: @place.id, filter_id: filter_id } unless PlaceFilter.exists?(place: @place, filter_id: filter_id)
        end.compact
        PlaceFilter.insert_all(place_filters_attributes)
      end

      base64_encoded_photos = prepare_files_for_job(filtered_photos_params)
      ImageProcessingJob.perform_later(base64_encoded_photos, @place.id)

      params[:place][:photos].each do |photo|
        size_in_megabytes = photo.size.to_f / (1024 * 1024)
        if size_in_megabytes > 5
          p "🔥 place photo too big #{size_in_megabytes > 5}"
        end
      end

      respond_to do |format|
        format.js
        format.html { redirect_to(current_user.admin? ? root_path : stripe_checkout_path) }
      end
    else
      flash[:alert] = @place.errors.full_messages.join(', ')
      redirect_to new_place_path
    end
  end

  # Renders a form for editing an existing place identified by id.
  def edit
    authorize @place
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }
  end

  # Updates an existing place record with the submitted form data.
  def update
    @place = Place.find(params[:id].to_i)
    authorize @place

    if @place.photos.attached?
      expire_place_show_photos_cache(@place)
    end

    if @place.update(place_params.except(:photos))
      if params[:place][:photos].count > 1
        @place.photos.purge
        params[:place][:photos].each do |photo|
          @place.photos.attach(photo)
        end
      end
      redirect_to place_path(@place), notice: 'Vše je v pořádku a aktualizováno.'
    else
      @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }
      render :edit, status: :unprocessable_entity
    end
  end

  # Deletes the place record identified by id.
  def destroy; end

  # Renders out all of the places for the admin to be able to change them
  def admin_places
    authorize :place
    @places = policy_scope(Place.all)
    @places = @places.order(:place_name)
  end

  # Allows admin to toggle the primary status
  def toggle_primary
    authorize @place
    flash[:notice] = if @place.primary? ? @place.update(primary: false) : @place.update(primary: true)
                       "Primary status of the place was successfully toggled to #{@place.primary}."
                     else
                       'There was an issue toggling the primary status of the place. Try again...'
                     end
    redirect_to place_path(@place)
  end

  private

  def check_photo_sizes?
    @place.errors.add(:photos, message: 'Fotky musí být uploadovány!') and return false unless params[:place][:photos].present?

    photos_over_5mb = params[:place][:photos].any? do |photo|
      size_in_megabytes = photo.size.to_f / (1024 * 1024)
      size_in_megabytes > 5
    end
    @place.errors.add(:photos, message: 'Každá fotka musí být pod 5MB') and return false if photos_over_5mb

    true
  end

  def prepare_files_for_job(uploaded_files)
    uploaded_files.map do |uploaded_file|
      next if uploaded_file.blank?

      {
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type,
        base64: Base64.encode64(uploaded_file.read)
      }
    end.compact
  end

  # Cache expiration keep here, when put in the model the controller destroys photos first then tries to retrieve cache.
  # First destroy cache then the Blobs (Photos)
  def expire_place_show_photos_cache(place)
    Rails.cache.delete([place, place.photos.first, 'card_image', place.photos.first.created_at])
    place.photos.each do |photo|
      Rails.cache.delete([photo, 'gallery', photo.created_at])
    end
  end

  def display_error_messages
    flash.now[:alert] = if place_params[:place_name].empty?
                          'Vyplňte prosím jméno vašeho prostoru'
                        elsif place_params[:street].empty?
                          'Vyplňte prosím jméno ulice'
                        elsif place_params[:house_number].empty?
                          'Vyplňte prosím číslo popisné'
                        elsif place_params[:postal_code].empty?
                          'Vyplňte prosím PSČ'
                        elsif place_params[:city].empty?
                          'Vyplňte prosím město'
                        elsif place_params[:max_capacity].empty?
                          'Vyplňte prosím maximální kapacitu'
                        elsif place_params[:short_description].empty?
                          'Vyplňte prosím krátký popis vašeho prostoru'
                        elsif place_params[:long_description].empty?
                          'Vyplňte prosím dlouhý popis vašeho prostoru'
                        elsif place_params[:photos].empty?
                          'Vyberte prosím fotky'
                        else
                          'Vyberte prosím filtry'
                        end
  end

  def set_place
    @place = Place.find(params[:id])
  end

  def place_params
    params.require(:place).permit(:place_name, :street, :house_number, :postal_code, :city, :max_capacity,
                                  :short_description, :long_description, photos: [], filter_ids: [])
  end
end
