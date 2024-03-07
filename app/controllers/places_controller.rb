# frozen_string_literal: true

# PlacesController manages actions related to Place resources including listing all places,
# showing details for a single place, creating new places, editing existing places, and
# deleting places. It responds to routes defined in config/routes.rb for the Place model.
class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show new update toggle_primary] # Skip authentication for index
  before_action :set_place, only: %i[show edit toggle_primary]

  # Lists all places.
  def index
    @places  = policy_scope(Place.visible)
    @filters = Filter.all

    if params[:filters].present?
      filter_ids = params[:filters].reject(&:empty?).map(&:to_i)
      if filter_ids.any?
        @places = @places.joins(:place_filters).where(place_filters: { filter_id: filter_ids }).distinct
      end
    end

    @places = @places.search_by_query(params[:query]) if params[:query].present?

    @places = @places.order(primary: :desc)

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

    authorize @place
    @order = Order.new
    @order.build_bokee
  end

  # Renders a form for creating a new place.
  def new
    @place   = Place.new
    @filters = Filter.all
    authorize @place
  end

  # Creates a new place record from the submitted form data.
  def create
    params_for_place  = place_params
    filter_ids        = place_params[:filter_ids].map(&:to_i) unless place_params[:filter_ids].nil?

    @place = Place.new(params_for_place)
    authorize @place

    @place.user = current_user

    if @place.save
      # If filter give you shadow bugs, the ampersand try deleting the ampersand infront of .each
      filter_ids&.each do |filter_id|
        PlaceFilter.create(place: @place, filter_id:) unless PlaceFilter.exists?(place: @place, filter_id:)
      end
      respond_to do |fromat|
        fromat.js
        fromat.html
      end
      redirect_to stripe_checkout_path
    else
      flash[:alert] = @place.errors.full_messages.join(', ')
      redirect_to new_place_path
    end
  end

  # Renders a form for editing an existing place identified by id.
  def edit
    authorize @place
    @filters = Filter.all
  end

  # Updates an existing place record with the submitted form data.
  def update
    @place   = Place.find(place_id)
    authorize @place

    if @place.update(place_params.except(:photos))
      if params[:place][:photos].count > 1
        @place.photos.purge
        params[:place][:photos].each do |photo|
          @place.photos.attach(photo)
        end
      end
      redirect_to place_path(@place), notice: 'Vše je v pořádku a aktualizováno.'
    else
      @filters = Filter.all
      render :edit, status: :unprocessable_entity
    end
  end

  # Deletes the place record identified by id.
  def destroy; end

  def admin_places
    authorize :place
    @places = policy_scope(Place.all)
    @places = @places.order(:place_name)
  end

  def toggle_primary
    authorize @place
    if @place.primary? ? @place.update(primary: false) : @place.update(primary: true)
      flash[:notice] = 'Primary status of the place was successfully toggled.'
      redirect_to place_path(@place)
    else
      flash[:notice] = 'There was an issue toggling the primary status of the place. Try again...'
      redirect_to place_path(@place)
    end
  end

  private

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

  # TODO: Check if we need :number_of_venues,
  def place_params
    params.require(:place).permit(:place_name, :street, :house_number, :postal_code, :city, :max_capacity,
                                  :short_description, :long_description, photos: [], filter_ids: [])
  end
end
