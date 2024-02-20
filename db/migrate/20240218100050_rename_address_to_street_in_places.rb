class RenameAddressToStreetInPlaces < ActiveRecord::Migration[7.1]
  def change
    rename_column :places, :address, :street
  end
end
