# frozen_string_literal: true

# Pages controller handles static and DB related pages.
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[landing_page about_us faq_contact_us contact overload new_bulk_order create_bulk_order] # Skip authentication for index

  # The landing_page action renders the application's landing page, which is used to explain
  # how it works, sample places/venues and a footer
  def landing_page
    @places = Rails.cache.fetch('sample_places', expires_in: 1.hour) do
      Place.visible
           .select(:id, :place_name, :short_description, :slug, :max_capacity, :street, :house_number, :postal_code, :city, :hidden, :primary)
           .includes(:filters).group(:id).sample(4)
    end
  end

  def about_us; end

  def faq_contact_us; end

  # Sends the email from contact us form
  def contact
    if turnstile_passed?
      ContactEmailJob.perform_later(contact_params)
      redirect_to root_path, notice: 'Vaše zpráva je již na cestě. Brzy se vám ozveme.'
    else
      render :faq_contact_us, status: :unprocessable_entity, alert: 'Bohužel se nepodařilo poslat vaší zprávu. Zkuste to prosím znovu.'
    end
  end

  # Static page serving as waiting room when the server/DBs are overloaded
  def overload; end

  # When person wants query multiple places at once
  def new_bulk_order
    @order   = Order.new
    @filters = Rails.cache.fetch('filters', expires_in: 12.hours) { Filter.all }
    @order.build_bokee
  end

  # Takes the params from new_bulk_order form. Uses strong params. Then validates them through BulkOrderForm model.
  # Creates a bokee, finds the ids of corresponding places and verfies captcha with bokee. If pass sends the query.
  def create_bulk_order
    recaptcha_passed = turnstile_passed?
    @order.errors.add(:base, 'Nepodařilo se ověřit jestli jste robot. Zkuste to prosím znovu.') unless recaptcha_passed

    @bokee = Bokee.create_with(bulk_order_params[:bokee_attributes]).find_or_create_by(email: bulk_order_params[:bokee_attributes][:email])
    place_ids = Place.joins(:filters).where(filters: { id: filters_params[:filter_ids].map!(&:to_i) })
                     .where('city LIKE ? OR city = ?', "#{bulk_order_params[:city]}%", bulk_order_params[:city])
                     .where('places.max_capacity >= ?', bulk_order_params[:min_capacity]).distinct.pluck(:id).map(&:to_i)

    if @bokee.save && recaptcha_passed && place_ids.present?
      place_ids.each do |place_id|
        order = Order.new(bulk_order_params.except(:bokee_attributes, :min_capacity, :city))
        order.bokee = @bokee
        order.place_id = place_id

        if order.save
          SendOrderToPlaceOwnerJob.perform_later(place_id, order.id)
        else
          flash.now[:alert] = (@order.errors.full_messages + @bokee.errors.full_messages).join(', ')
          render :new_bulk_order, status: :unprocessable_entity
        end
      end

      redirect_to root_path, notice: 'Zpracováváme Vaší hromadnou poptávku'
    else
      flash.now[:alert] = (@order.errors.full_messages + @bokee.errors.full_messages).join(', ')
      render :new_bulk_order, status: :unprocessable_entity
    end
  end

  private

  def filters?
    filters_params[:filter_ids].length.positive?
  end

  def bulk_order_params
    params.require(:order).permit(:message, :event_type, :min_capacity, :city, :date, bokee_attributes: %i[full_name email phone_number])
  end

  def filters_params
    params.require(:place).permit(filter_ids: [])
  end

  def contact_params
    params.permit(:name, :email, :message, :subject)
  end
end
