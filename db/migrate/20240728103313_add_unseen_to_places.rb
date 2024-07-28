class AddUnseenToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :unseen, :boolean, default: true
  end
end
