# frozen_string_literal: true

class AddUniqueIndexToPlaceNames < ActiveRecord::Migration[7.1]
  def change
    add_index :places, :place_name, unique: true
  end
end
