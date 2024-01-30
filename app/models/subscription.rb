# frozen_string_literal: true

# Subscription ties a User to a SubscriptionPlan and stores details about
# the Stripe subscription, including IDs, payment intervals, and active status.
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan
end
