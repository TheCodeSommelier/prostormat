# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  # TODO: validations and how to get the messages from them into the flashes
  belongs_to :user
  has_many :orders, dependent: :destroy
  has_many :place_filters, dependent: :destroy
  has_many :filters, through: :place_filters
  has_many_attached :photos

  validates :max_capacity, numericality: { only_integer: true, greater_than: 10, message: 'Kapacita musí být alespoň 10' }
  validates :postal_code, format: { with: /\A\d{3}\s\d{2}\z/, message: 'Musí být psáno ve formátu "123 22"' }

  validates :place_name, :street, format: { with: /\A[\w\s]+\z/, message: 'Povolené znaky pro jméno prostoru jsou "_", písmena, čísla a mezery' } # Allows for underscores, letters, numbers and spaces
  validates :short_description, length: { in: 30..100, message: 'Musí být alespoň 30 znaků dlouhá, ale ne víc než 100' }

  validates :long_description, length: { minimum: 120, message: 'Musí být alespoň 120 znaků dlouhá' }

  validate :must_have_at_least_one_filter
  validate :custom_validation_presence

  scope :search_by_query, lambda { |query|
    where('LOWER(city) LIKE LOWER(?) OR LOWER(street) LIKE LOWER(?)', "%#{query}%", "%#{query}%")
  }
  scope :visible, -> { where(hidden: false) }

  private

  def custom_validation_presence
    fields = {
      place_name: 'Jméno prostoru',
      street: 'Ulice',
      city: 'Číslo popisné',
      postal_code: 'PSČ',
      max_capacity: 'Maximální kapacita',
      short_description: 'Krátký popis',
      long_description: 'Dlouhý popis'
    }
    fields.each do |field, field_name|
      if self.send(field).blank?
        errors.add(field_name, 'pole nemůže být prázdné.')
      end
    end
  end

  def must_have_at_least_one_filter
    errors.add(:filters, 'Vyberte alespoň jeden filtr') if filters.empty?
  end
end
