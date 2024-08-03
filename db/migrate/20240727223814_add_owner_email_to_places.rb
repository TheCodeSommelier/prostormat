# frozen_string_literal: true

class AddOwnerEmailToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :owner_email, :string
  end
end
