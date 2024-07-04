# frozen_string_literal: true

class AddPostalCodeToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :postal_code, :string
  end
end
