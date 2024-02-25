class AddHiddenToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :hidden, :boolean, default: true
  end
end
