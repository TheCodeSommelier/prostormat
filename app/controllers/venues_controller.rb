# frozen_string_literal: true

# VenuesController manages actions related to Venue resources. It handles the
# display of a single venue, editing venue details, updating venue information,
# and deleting a venue. It responds to routes defined in config/routes.rb for
# the Venue model.
class VenuesController < ApplicationController
  # Displays the details of a specific venue.
  def show; end

  # Renders a form for editing the details of a specific venue.
  def edit; end

  # Updates the details of a specific venue with the submitted form data.
  def update; end

  # Deletes the specified venue from the database.
  def destroy; end
end
