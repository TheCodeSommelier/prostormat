# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  belongs_to :user
  has_many :venues, dependent: :destroy
  has_many :place_filters, dependent: :destroy
  has_many :filters, through: :place_filters

  accepts_nested_attributes_for :venues

  def largest_venue_capacity
    venues.order(capacity: :desc).first.capacity
  end

  def smallest_venue_capacity
    venues.order(capacity: :asc).first.capacity
  end

  scope :search_by_query, ->(query) {
    where("LOWER(city) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
  }
end
