# frozen_string_literal: true

class AddCityToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :city, :string
  end
end
