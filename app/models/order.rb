# frozen_string_literal: true

# Order represents a transaction between a Bokee and a Venue where an event
# type is booked. It belongs to both a Bokee and a Venue.
class Order < ApplicationRecord
  # TODO: Form for order
  belongs_to :bokee
  belongs_to :venue
end
