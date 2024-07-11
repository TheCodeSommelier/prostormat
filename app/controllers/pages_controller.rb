# frozen_string_literal: true

# Pages controller handles static and DB related pages.
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[landing_page about_us faq_contact_us contact overload new_bulk_order create_bulk_order] # Skip authentication for index
  # The landing_page action renders the application's landing page, which is used to explain
  # how it works, sample places/venues and a footer
  def landing_page
    @places = Rails.cache.fetch('sample_places', expires_in: 1.hour) do
      Place.all.sample(4)
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
    recaptcha_passed = verify_recaptcha?(params[:recaptcha_token], 'bulk_order_new')
    unless recaptcha_passed
      @bulk_order_form.errors.add(:base,
                                  'reCAPTCHA verifikace se nepodařila. Zkuste to prosím znovu.')
    end

    @bokee = Bokee.new(full_name: bulk_order_params[:full_name], email: bulk_order_params[:email],
                       phone_number: bulk_order_params[:phone_number])

    # TODO: Potentially could be in the model
    places_ids = Place.joins(:filters).where(filters: { id: filters_params[:filter_ids].map!(&:to_i) })
                      .where('city LIKE ? OR city = ?', "#{bulk_order_params[:city]}%", bulk_order_params[:city])
                      .where('places.max_capacity >= ?', bulk_order_params[:min_capacity]).distinct.pluck(:id)

    if @bokee.save && recaptcha_passed && @bulk_order_form.valid?
      SendBulkOrderJob.perform_later(places_ids, bulk_order_params[:email], bulk_order_params[:name])
      redirect_to root_path, notice: 'Zpracováváme Vaší hromadnou poptávku'
    else
      flash.now[:alert] = (@bulk_order_form.errors.full_messages + @bokee.errors.full_messages).join(', ')
      render :new_bulk_order, status: :unprocessable_entity
    end
  end

  private

  def filters?
    filters_params[:filter_ids].length.positive?
  end

  def bulk_order_params
    params.require(:bulk_order_form).permit(:full_name, :email, :phone_number, :min_capacity, :city)
  end

  def filters_params
    params.require(:place).permit(filter_ids: [])
  end

  def contact_params
    params.permit(:name, :email, :message)
  end
end
