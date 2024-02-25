# frozen_string_literal: true

# PlacesController manages actions related to Place resources including listing all places,
# showing details for a single place, creating new places, editing existing places, and
# deleting places. It responds to routes defined in config/routes.rb for the Place model.
class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show new] # Skip authentication for index

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
    @place = Place.find(params[:id])
    authorize @place

    @filters = @place.filters
    @order   = Order.new
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
    filter_ids        = place_params[:filter_ids].each(&:to_i)

    @place = Place.new(params_for_place)
    authorize @place

    @place.user = current_user

    if @place.save
      filter_ids.each do |filter_id|
        unless PlaceFilter.exists?(place: @place, filter_id: filter_id)
          PlaceFilter.create(place: @place, filter_id: filter_id)
        end
      end
      respond_to do |fromat|
        fromat.js
        fromat.html
      end
      redirect_to stripe_checkout_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Renders a form for editing an existing place identified by id.
  def edit; end

  # Updates an existing place record with the submitted form data.
  def update; end

  # Deletes the place record identified by id.
  def destroy; end

  private

  def set_place
    @place = Place.find(params[:id])
  end

  # TODO: Check if we need :number_of_venues,
  def place_params
    params.require(:place).permit(:place_name, :street, :house_number, :postal_code, :city, :max_capacity,
                                  :short_description, :long_description, photos: [], filter_ids: [])
  end
end
