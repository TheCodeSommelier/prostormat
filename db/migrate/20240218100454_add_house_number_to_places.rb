class AddHouseNumberToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :house_number, :string
  end
end
