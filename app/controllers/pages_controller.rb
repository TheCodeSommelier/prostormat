# frozen_string_literal: true

# PagesController handles static pages that do not require complex logic or interaction
# with the application's models. It's typically used for informational or "brochure" pages
# within the application, such as the homepage, about page, contact page, etc.
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[landing_page about_us faq_contact_us contact] # Skip authentication for index
  # The landing_page action renders the application's landing page, which is used to explain
  # how it works, sample places/venues and a footer
  def landing_page
    @places = Place.all.sample(2)
    ActiveRecord::Base.connection_pool.release_connection
  end

  def about_us; end

  def faq_contact_us; end

  def contact
    ContactEmailJob.perform_later(contact_params)
  end

  private

  def contact_params
    params.permit(:name, :email, :message)
  end
end
