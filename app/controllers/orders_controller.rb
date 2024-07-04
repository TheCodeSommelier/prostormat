# frozen_string_literal: true

# OrdersController handles HTTP requests related to order operations such as
# creating a new order. It responds to routes defined in config/routes.rb.
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[create] # Skip authentication for create

  # Creates a new order with the provided parameters.
  def create
    @order       = Order.new(orders_params.except(:bokee_attributes))
    place_id     = params[:place_id].to_i
    @place       = Place.find(place_id)
    @order.place = @place

    authorize @order

    bokee        = Bokee.create_with(orders_params[:bokee_attributes]).find_or_create_by(email: orders_params[:bokee_attributes][:email])
    @order.bokee = bokee

    if @order.save && verify_recaptcha
      SendOrderToPlaceOwnerJob.perform_later(@place.id, bokee.id, @order.message)
      redirect_to place_path(@place.slug), notice: 'Poptávka je vytvořená. Majitel se Vám ozve.'
    else
      redirect_to place_path(@place.slug), alert: display_error_messages
    end
  end

  private

  # Displays a an error message with the corresponding problem
  def display_error_messages
    flash.now[:alert] = if orders_params[:event_type].empty?
                          'Typ eventu nemůže být prázdný'
                        elsif orders_params[:date].empty?
                          'Vyberte datum'
                        elsif orders_params[:bokee_attributes][:full_name].empty?
                          'Dejte nám své jméno'
                        elsif orders_params[:bokee_attributes][:email].empty?
                          'Vyplňte svůj email'
                        elsif orders_params[:bokee_attributes][:phone_number].empty?
                          'Vyplňte svoje telefonní číslo'
                        else
                          'Něco se pokazilo skuste to znovu...'
                        end
  end

  def orders_params
    params.require(:order).permit(:event_type, :date, :message, bokee_attributes: %i[full_name email phone_number])
  end
end
