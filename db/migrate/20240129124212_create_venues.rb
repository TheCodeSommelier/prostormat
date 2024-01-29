class CreateVenues < ActiveRecord::Migration[7.1]
  def change
    create_table :venues do |t|
      t.references :place, null: false, foreign_key: true
      t.integer :capacity
      t.text :description
      t.string :venue_name

      t.timestamps
    end
  end
end
