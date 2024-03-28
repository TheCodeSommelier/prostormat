# frozen_string_literal: true

# PagesController handles static pages that do not require complex logic or interaction
# with the application's models. It's typically used for informational or "brochure" pages
# within the application, such as the homepage, about page, contact page, etc.
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[landing_page about_us faq_contact_us contact overload new_bulk_order create_bulk_order] # Skip authentication for index
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
    @bulk_order_form = BulkOrderForm.new
    @filters         = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all }
  end

  def create_bulk_order
    @bulk_order_form = BulkOrderForm.new(bulk_order_params)

    unless @bulk_order_form.valid?
      flash[:alert] = 'Vyplaňte prosím všechny pole a vyberte alespoň jeden filtr'
      redirect_to new_bulk_order_path and return
    end

    places_ids = Place.joins(:filters)
                      .where(filters: { id: bulk_order_params[:filter_ids] })
                      .where("city LIKE ? OR city = ?", "#{bulk_order_params[:city]}%", bulk_order_params[:city])
                      .where('places.max_capacity >= ?', bulk_order_params[:min_capacity])
                      .distinct
                      .pluck(:id)

    if verify_recaptcha
      SendBulkOrderJob.perform_later(places_ids, bulk_order_params[:email], bulk_order_params[:name])
      flash[:notice] = 'Zpracováváme Vaší hromadnou poptávku'
      redirect_to root_path
    else
      flash.now[:alert] = 'reCAPTCHA verifikace se nepodařila. Zkuste to prosím znovu.'
      render :new_bulk_order
    end
  end

  private

  def bulk_order_params
    params.require(:bulk_order_form).permit(:name, :email, :min_capacity, :city, filter_ids: [])
  end

  def contact_params
    params.permit(:name, :email, :message)
  end
end
