# frozen_string_literal: true

class AddCancelColumnToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :cancelled, :boolean
  end
end
