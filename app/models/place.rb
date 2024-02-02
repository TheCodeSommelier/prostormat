# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  belongs_to :user
  has_many :venues, dependent: :destroy

  def largest_venue_capacity
    venues.order(capacity: :desc).first.capacity
  end

  def smallest_venue_capacity
    venues.order(capacity: :asc).first.capacity
  end

  scope :filter_by_tag, lambda { |tags|
    tags.present? ? where('tags @> ARRAY[:tags]::varchar[]', tags:).distinct : all
  }

  scope :filter_by_city, lambda { |city|
    city.present? ? where(city:).distinct : all
  }
end
