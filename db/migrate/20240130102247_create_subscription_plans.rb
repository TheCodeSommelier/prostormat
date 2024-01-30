class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :plan_type
      t.integer :yearly_price

      t.timestamps
    end
  end
end
