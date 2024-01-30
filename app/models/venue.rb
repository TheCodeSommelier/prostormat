# frozen_string_literal: true

# Venue represents a specific location within a Place that can host events.
# It has a relationship to Place and can have many orders. Through orders,
# it is indirectly associated with Bokees (bookers).
class Venue < ApplicationRecord
  belongs_to :place
  has_many :orders
  has_many :bokees, through: :orders
end
