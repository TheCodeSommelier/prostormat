# frozen_string_literal: true

class AddPremiumColumnTousers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :premium, :boolean, default: false
  end
end
