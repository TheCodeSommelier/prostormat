class AddFreeTrialStartToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :free_trial_start, :timestamp
  end
end
