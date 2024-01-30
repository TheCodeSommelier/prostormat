# frozen_string_literal: true

# SubscriptionPlan describes the different plans available to Users.
# It stores plan types and their associated yearly pricing.
class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions
end
