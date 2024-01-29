class CreateBokees < ActiveRecord::Migration[7.1]
  def change
    create_table :bokees do |t|
      t.string :phone_number
      t.string :email
      t.string :full_name

      t.timestamps
    end
  end
end
