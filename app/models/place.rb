# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  # TODO: validations
  belongs_to :user
  has_many :orders, dependent: :destroy
  has_many :place_filters, dependent: :destroy
  has_many :filters, through: :place_filters
  has_many_attached :photos

  validates :place_name, :street, :city, :house_number, :postal_code, :max_capacity, :short_description, :long_description, presence: true
  validates :max_capacity, numericality: { only_integer: true, greater_than: 10 }
  validates :postal_code, format: { with: /\A\d{3}\s\d{2}\z/, message: 'Musí být ve formátu 123 45' }
  validates :place_name, :street, format: { with: /\A[\w\s]+\z/ } # Allows for underscores, letters, numbers and spaces
  validate :must_have_at_least_one_filter

  scope :search_by_query, lambda { |query|
    where('LOWER(city) LIKE LOWER(?) OR LOWER(street) LIKE LOWER(?)', "%#{query}%", "%#{query}%")
  }
  scope :visible, -> { where(hidden: false) }

  private

  def must_have_at_least_one_filter
    errors.add(:filters, 'must choose at least one') if filters.empty?
  end
end
