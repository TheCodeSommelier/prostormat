class RenameFreeTrialStartInPlaces < ActiveRecord::Migration[7.1]
  def change
    rename_column :places, :free_trial_start, :free_trial_end
  end
end
