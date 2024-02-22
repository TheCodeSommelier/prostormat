class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :bokee, null: false, foreign_key: true
      t.string :event_type

      t.timestamps
    end
  end
end
