# frozen_string_literal: true

# Place represents a property owned by a User where multiple Venues can exist.
# A Place has many Venues associated with it and deleting a Place will also
# delete its associated Venues (dependent: :destroy).
class Place < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :destroy
  has_many :place_filters, dependent: :destroy
  has_many :filters, through: :place_filters
  has_many_attached :photos

  # Callback that expires cache upon creation or editation of a place record
  after_commit :expire_places_index_cache, on: %i[create update]
  after_commit :expire_place_show_cache, on: :update

  validates :max_capacity,
            numericality: { only_integer: true, greater_than: 10, message: 'Kapacita musí být alespoň 10' }
  validates :postal_code, format: { with: /\A\d{3}\s\d{2}\z/, message: 'Musí být psáno ve formátu "123 22"' }

  # Regexp allows for underscores, letters, numbers and spaces
  validates :place_name,
            format: { with: /[\p{L}\s\d_]+/u,
                      message: 'Povolené znaky pro jméno prostoru jsou: 1. "_" 2. písmena 3. čísla 4. mezery' }

  # Regexp allows for letters and spaces
  validates :street, format: { with: /[\p{L}\s]+/u, message: 'Povolené znaky pro ulici jsou písmena a mezery' }

  validates :short_description, length: { in: 10..50, message: 'Musí být alespoň 10 až 50 znaků dlouhá' }
  validates :long_description, length: { minimum: 120, message: 'Musí být alespoň 120 znaků dlouhá' }

  validate :must_have_at_least_one_filter
  validate :custom_validation_presence

  # This is a case insesitive query, for the search on the index page
  scope :search_by_query, lambda { |query|
    where('LOWER(city) LIKE LOWER(?) OR LOWER(street) LIKE LOWER(?)', "%#{query}%", "%#{query}%")
  }

  # Selects only the places where the hidden is set to false e.g. the places of which owners have an active subscription
  scope :visible, -> { where(hidden: false) }

  def full_address
    "#{street} #{house_number}, #{postal_code}, #{city}"
  end

  def self.related_places(place, filter_ids, base_city_name)
    joins(:filters).where(filters: { id: filter_ids }).where.not(id: place.id)
                   .where('city LIKE ?', "#{base_city_name}%").order(primary: :desc).distinct
                   .limit(2)
  end

  private

  def expire_places_index_cache
    Rails.cache.delete('places/index')
  end

  def expire_place_show_cache
    Rails.cache.delete("place_#{id}")
    Rails.cache.delete("place_#{id}_address")
    Rails.cache.delete([self, 'google_api_map'])

    filter_ids               = filters.pluck(:id)
    base_city_name           = city.split(' ').first
    related_places_cache_key = [
      'related_places',
      id,
      filter_ids.sort.join('-'),
      base_city_name,
      Place.maximum(:updated_at)
    ]
    Rails.cache.delete(related_places_cache_key)
  end

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
      errors.add(field_name, 'pole nemůže být prázdné.') if send(field).blank?
    end
  end

  def must_have_at_least_one_filter
    errors.add(:filters, 'Vyberte alespoň jeden filtr') if filters.empty?
  end
end
