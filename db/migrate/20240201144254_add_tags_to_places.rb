class AddTagsToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :tags, :string, array: true, default: []
  end
end
