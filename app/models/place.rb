# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  # TODO: payment gate after place create
  belongs_to :user
  has_many :orders, dependent: :destroy
  has_many :place_filters, dependent: :destroy
  has_many :filters, through: :place_filters
  has_many_attached :photos

  scope :search_by_query, lambda { |query|
    where('LOWER(city) LIKE LOWER(?) OR LOWER(address) LIKE LOWER(?)', "%#{query}%", "%#{query}%")
  }
  scope :visible, -> { where(hidden: false) }
end
