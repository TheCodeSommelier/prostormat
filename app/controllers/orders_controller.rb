# frozen_string_literal: true

# OrdersController handles HTTP requests related to order operations such as
# creating a new order. It responds to routes defined in config/routes.rb.
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[create] # Skip authentication for create

  # Creates a new order with the provided parameters.
  def create
    @order           = Order.new(orders_params.except(:bokee_attributes))
    @place           = if validate_place_id?
                         Place.find(params[:place_id].to_i)
                       else
                         @order.errors.add(:base,
                                           'Parametr place_id není platný')
                       end
    @order.place     = @place if @place.is_a?(Place)
    recaptcha_passed = verify_recaptcha?(params[:recaptcha_token], 'order_new')
    error_message    = 'Google vyhodnotil rizikovou aktivitu. Zkuste to prosím znovu a mimo icognito mód...'

    authorize @order

    bokee           = Bokee.create_with(orders_params[:bokee_attributes]).find_or_create_by(email: orders_params[:bokee_attributes][:email])
    @order.bokee    = bokee
    @order.errors.add(:base, error_message) unless recaptcha_passed

    if @order.save && recaptcha_passed && validate_place_id?
      SendOrderToPlaceOwnerJob.perform_later(@place.id, bokee.id, @order.message)
      redirect_to place_path(@place.slug), notice: 'Poptávka je vytvořená. Majitel se Vám ozve.'
    else
      redirect_to place_path(@place.slug), alert: @order.errors.full_messages.join(', ')
    end
  end

  private

  def orders_params
    params.require(:order).permit(:event_type, :date, :message, bokee_attributes: %i[full_name email phone_number])
  end

  def validate_place_id?
    params[:place_id].to_i.is_a?(Integer)
  end
end
