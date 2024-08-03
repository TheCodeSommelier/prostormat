# frozen_string_literal: true

class AddDeliveredAtToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :delivered_at, :timestamp, default: nil
  end
end
