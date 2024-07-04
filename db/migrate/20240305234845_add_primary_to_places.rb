# frozen_string_literal: true

class AddPrimaryToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :primary, :boolean, default: false
  end
end
