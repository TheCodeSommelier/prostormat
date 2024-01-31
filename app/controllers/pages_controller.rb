# frozen_string_literal: true

# PagesController handles static pages that do not require complex logic or interaction
# with the application's models. It's typically used for informational or "brochure" pages
# within the application, such as the homepage, about page, contact page, etc.
class PagesController < ApplicationController
  # The landing_page action renders the application's landing page, which is used to explain
  # how it works, sample places/venues and a footer
  def landing_page
    @random_places = Place.all.sample(8)
  end
end
