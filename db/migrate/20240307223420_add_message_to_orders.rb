# frozen_string_literal: true

class AddMessageToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :message, :text
  end
end
