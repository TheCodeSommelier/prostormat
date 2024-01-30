# frozen_string_literal: true

# Bokee represents an entity that books Venues. It has many Orders
# and is associated with the Venues it books through those orders.
class Bokee < ApplicationRecord
  has_many :orders
end
