# frozen_string_literal: true

# PagesController handles static pages that do not require complex logic or interaction
# with the application's models. It's typically used for informational or "brochure" pages
# within the application, such as the homepage, about page, contact page, etc.
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[landing_page about_us faq_contact_us contact] # Skip authentication for index
  # The landing_page action renders the application's landing page, which is used to explain
  # how it works, sample places/venues and a footer
  def landing_page
    @places = Rails.cache.fetch('sample_places', expires_in: 1.hour) do
      Place.all.sample(2)
    end
  end

  def about_us; end

  def faq_contact_us; end

  def contact
    ContactEmailJob.perform_later(contact_params)
    redirect_to root_path, notice: 'Vaše zpráva se odesílá. Brzy se vám ozveme.'
  end

  def overload; end

  def new_bulk_order
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all }
  end

  def create_bulk_order
    # Preload places and their owners based on params (filters, city, max capacity)
    # Iterate over places and build out email hashes
  end

  private

  def contact_params
    params.permit(:name, :email, :message)
  end
end
