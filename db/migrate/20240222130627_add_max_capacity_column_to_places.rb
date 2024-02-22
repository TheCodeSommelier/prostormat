class AddMaxCapacityColumnToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :max_capacity, :integer
  end
end
