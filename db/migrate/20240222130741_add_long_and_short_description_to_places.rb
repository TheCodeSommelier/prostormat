class AddLongAndShortDescriptionToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :long_description, :text
    add_column :places, :short_description, :text
  end
end
