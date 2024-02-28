class AddPlaceIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :place, null: false, foreign_key: true
  end
end
