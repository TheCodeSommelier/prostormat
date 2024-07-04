# frozen_string_literal: true

class RemoveTimeColumnFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :time, :time
  end
end
