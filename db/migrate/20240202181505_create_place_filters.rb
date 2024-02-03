class CreatePlaceFilters < ActiveRecord::Migration[7.1]
  def change
    create_table :place_filters do |t|
      t.references :place, null: false, foreign_key: true
      t.references :filter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
