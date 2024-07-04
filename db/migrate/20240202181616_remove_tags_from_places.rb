# frozen_string_literal: true

class RemoveTagsFromPlaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :places, :tags
  end
end
