# frozen_string_literal: true

# PlacesController manages actions related to Place resources including listing all places,
# showing details for a single place, creating new places, editing existing places, and
# deleting places. It responds to routes defined in config/routes.rb for the Place model.
class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show] # Skip authentication for index

  # Lists all places.
  def index
    @places = policy_scope(Place)
    @filters = Filter.all

    if params[:filters].present?
      filter_ids = params[:filters].reject(&:empty?).map(&:to_i)
      if filter_ids.any?
        @places = @places.joins(:place_filters).where(place_filters: { filter_id: filter_ids }).distinct
      end
    end

    @places = @places.search_by_query(params[:query]) if params[:query].present?
  end

  # Shows details for a single place identified by id.
  def show
    @place = Place.find(params[:id])
    authorize @place

    @filters = @place.filters

    @venues = Venue.where(place: @place)

    @order = Order.new
  end

  # Renders a form for creating a new place.
  def new; end

  # Creates a new place record from the submitted form data.
  def create; end

  # Renders a form for editing an existing place identified by id.
  def edit; end

  # Updates an existing place record with the submitted form data.
  def update; end

  # Deletes the place record identified by id.
  def destroy; end
end
