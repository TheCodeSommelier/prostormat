class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :payment_interval
      t.date :start_date
      t.date :end_date
      t.boolean :active
      t.boolean :cancel_at_current_period_end
      t.string :stripe_sub_status

      t.timestamps
    end
  end
end
