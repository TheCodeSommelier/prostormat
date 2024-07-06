# frozen_string_literal: true

# PlacesController manages actions related to Place resources including listing all places,
# showing details for a single place, creating new places, editing existing places, and
# deleting places. It responds to routes defined in config/routes.rb for the Place model.
class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show new update toggle_primary] # Skip authentication for index
  before_action :set_place, only: %i[edit toggle_primary transfer]

  # Lists and caches all visible places.
  def index
    @places  = Rails.cache.fetch('places/index', expires_in: 1.hour) { Place.visible }
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }

    policy_scope(@places)
    # Apply filters
    if params[:place].present? && params[:place][:filter_ids].present?
      filter_ids = params[:place][:filter_ids].reject(&:empty?).map(&:to_i)
      if filter_ids.any?
        @places = @places.joins(:place_filters).where(place_filters: { filter_id: filter_ids }).distinct
      end
    end

    # Search by address or city
    @places = @places.search_by_query(params[:query]) if params[:query].present?

    # Filter by capacity 'from' and 'to'
    @places = if !params[:min_capacity].present? && params[:max_capacity].present?
                @places.where('max_capacity <= ?', params[:max_capacity])
              elsif params[:min_capacity].present? && params[:max_capacity].present?
                @places.where('max_capacity >= ? AND max_capacity <= ?', params[:min_capacity], params[:max_capacity])
              elsif params[:min_capacity].present?
                @places.where('max_capacity >= ?', params[:min_capacity])
              else
                @places
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
    @place = Rails.cache.fetch("place_#{params[:slug]}") { Place.find_by(slug: params[:slug]) }
    authorize @place

    # This encodes the address into a url for google maps api
    @place_encoded_address = Rails.cache.fetch("place_#{params[:slug]}_address") do
      CGI.escape("#{@place.street} #{@place.house_number}, #{@place.postal_code}, #{@place.city}")
    end

    @order = Order.new
    @order.build_bokee

    filter_ids     = @place.filters.pluck(:id)
    base_city_name = @place.city.split(' ').first
    cache_key      = ['related_places', @place.id, filter_ids.sort.join('-'), base_city_name,
                      Place.maximum(:updated_at)]

    @marker_overlay = "pin-s-l+26A387(#{@place.longitude},#{@place.latitude})"
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
    @place = Place.new(place_params)
    authorize @place
    @place.user = current_user
    @place.hidden = false if current_user.admin?

    if check_photo_sizes? && filters? && @place.save
      process_photos
      respond_to do |format|
        format.js
        format.html { redirect_to(current_user.admin? ? root_path : stripe_checkout_path) }
      end
    else
      @filters = Filter.all.to_a
      flash.now[:alert] = @place.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  # Renders a form for editing an existing place identified by id.
  def edit
    authorize @place
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }
    @place_filters = @place.filters.map(&:name)
  end

  # Updates an existing place record with the submitted form data.
  def update
    @place = Place.find_by(slug: params[:slug])
    authorize @place

    expire_place_show_photos_cache(@place) if @place.photos.attached?

    if @place.update(place_params.except(:photos, :filters)) && params[:change_pics].to_i.zero? || @place.update(place_params.except(:photos, :filters)) && params[:change_pics].to_i == 1 && check_photo_sizes?
      flash_message = params[:change_pics] == 1 ? 'Vše je v pořádku a aktualizováno. Dejte nám chvíli na nahrání vyšich fotek a znovu načtěte stránku.' : 'Vše je v pořádku a aktualizováno.'
      if params[:change_pics].to_i == 1
        @place.photos.purge
        filtered_photos_params = place_params[:photos].reject(&:blank?)
        base64_encoded_photos = prepare_files_for_job(filtered_photos_params)
        ImageProcessingJob.perform_later(base64_encoded_photos, @place.id)
      end
      redirect_to place_path(@place.slug), notice: flash_message
    else
      @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all.to_a }
      flash.now[:alert] =
        "Bohužel Váš prostor se nepodařilo aktualizovat z důvodu: #{@place.errors.full_messages.join(', ')}"
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
    redirect_to place_path(@place.slug)
  end

  # Transfers the place to a new user
  def transfer
    authorize @place
    other_user_email = transfer_params[:user_email]
    other_user = User.find_by(email: other_user_email)

    if other_user
      hidden_status = other_user.premium ? false : true
      @place.update_columns(user_id: other_user.id, hidden: hidden_status, updated_at: DateTime.now)
      redirect_to admin_places_path, notice: "Prostor #{@place.place_name} je převedený #{@place.user.email}"
    else
      redirect_to admin_places_path, alert: 'Prostor se nepodařilo převést. Uživatel nemá vytvořený účet.'
    end
  end

  private

  def process_photos
    filtered_photos_params = params[:place][:photos].reject(&:blank?) if params[:place][:photos]
    if filtered_photos_params.present?
      base64_encoded_photos = prepare_files_for_job(filtered_photos_params)
      ImageProcessingJob.perform_later(base64_encoded_photos, @place.id)
    end
  end

  def transfer_params
    params.permit(:user_email)
  end

  def check_photo_sizes?
    unless params[:place][:photos].reject(&:blank?).count >= 3
      @place.errors.add(:photos,
                        message: 'Alespoň 3 fotky musí být uploadovány!') and return false
    end

    photos_oversize = params[:place][:photos].any? do |photo|
      size_in_megabytes = photo.size.to_f / (1024 * 1024)
      size_in_megabytes > 7
    end
    @place.errors.add(:photos, message: 'Každá fotka musí být pod 7MB') and return false if photos_oversize

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
    @place = Place.find_by(slug: params[:slug])
  end

  def filters?
    flash.now[:alert] = 'Vyberte prosím alespoň jeden filtr' unless place_params[:filter_ids].length.positive?
    place_params[:filter_ids].length.positive?
  end

  def place_params
    params.require(:place).permit(:slug, :place_name, :street, :house_number, :postal_code, :city, :max_capacity,
                                  :short_description, :long_description, photos: [], filter_ids: [])
  end
end
