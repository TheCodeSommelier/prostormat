# frozen_string_literal: true

class AddTimeDetailsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :date, :date
    add_column :orders, :time, :time
  end
end
