# frozen_string_literal: true

# OrdersController handles HTTP requests related to order operations such as
# creating a new order, updating an existing order, or potentially canceling an order.
# It responds to routes defined in config/routes.rb.
class OrdersController < ApplicationController
  # Creates a new order with the provided parameters.
  def create
    @order       = Order.new(orders_params.except(:bokee_attributes))
    place_id     = params[:place_id].to_i
    place        = Place.find(place_id)
    @order.place = place

    authorize @order

    bokee = @order.build_bokee(orders_params[:bokee_attributes])

    if @order.save && bokee.save
      flash.now[:notice] = 'Poptávka je vytvořená. Majitel se Vám ozve.'
      redirect_to place_path(place)
    else
      flash.now[:alert] = 'Něco se pokazilo zkuste to znovu prosím...'
      render "places/#{place_id}"
    end
  end

  # Updates an existing order, potentially used for canceling for tax purposes.
  def update; end

  private

  def orders_params
    params.require(:order).permit(:event_type, :date, :time, bokee_attributes: %i[full_name email phone_number])
  end
end
