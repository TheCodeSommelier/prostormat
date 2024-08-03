# frozen_string_literal: true

class AddNotifiedToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :notified, :boolean, default: false
  end
end
