class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.references :user, null: false, foreign_key: true
      t.string :place_name
      t.string :address

      t.timestamps
    end
  end
end
