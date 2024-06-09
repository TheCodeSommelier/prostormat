# frozen_string_literal: true

# Pages controller handles static and DB related pages.
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

  # Sends the email from contact us form
  def contact
    ContactEmailJob.perform_later(contact_params)
    redirect_to root_path, notice: 'Vaše zpráva se odesílá. Brzy se vám ozveme.'
  end

  # Static page serving as waiting room when the server/DBs are overloaded
  def overload; end

  # When person wants query multiple places at once
  def new_bulk_order
    @bulk_order_form = BulkOrderForm.new
    @filters         = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all }
  end

  # Takes the params from new_bulk_order form. Uses strong params. Then validates them through BulkOrderForm model.
  # Creates a bokee, finds the ids of corresponding places and verfies captcha with bokee. If pass sends the query.
  def create_bulk_order
    @bulk_order_form = BulkOrderForm.new(bulk_order_params)

    unless @bulk_order_form.valid?
      flash[:alert] = 'Vyplaňte prosím všechny pole a vyberte alespoň jeden filtr'
      redirect_to new_bulk_order_path and return
    end

    @bokee = Bokee.new(full_name: bulk_order_params[:name], email: bulk_order_params[:email], phone_number: bulk_order_params[:phone_number])

    # TODO: Potentially could be in the model
    places_ids = Place.joins(:filters)
                      .where(filters: { id: bulk_order_params[:filter_ids] })
                      .where("city LIKE ? OR city = ?", "#{bulk_order_params[:city]}%", bulk_order_params[:city])
                      .where('places.max_capacity >= ?', bulk_order_params[:min_capacity])
                      .distinct
                      .pluck(:id)

    if verify_recaptcha && @bokee.save
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
    params.require(:bulk_order_form).permit(:name, :email, :phone_number, :min_capacity, :city, filter_ids: [])
  end

  def contact_params
    params.permit(:name, :email, :message)
  end
end
