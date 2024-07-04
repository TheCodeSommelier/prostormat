# frozen_string_literal: true

class AddDevToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :dev, :boolean, default: false
  end
end
