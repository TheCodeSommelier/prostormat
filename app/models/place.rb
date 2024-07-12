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

  after_validation :generate_slug, on: %i[create update]

  geocoded_by :full_address
  after_validation :geocode, if: :full_address_changed?

  # Callback that expires cache upon creation or editation of a place record
  after_commit :expire_places_index_cache, on: %i[create update]
  after_commit :expire_place_show_cache, on: :update

  validates :max_capacity,
            numericality: { only_integer: true, greater_than: 9, message: 'Kapacita musí být alespoň 10' }
  validates :postal_code, format: { with: /\A\d{3}\s\d{2}\z/, message: 'Musí být psáno ve formátu "123 22"' }

  # Regexp allows for underscores, letters, numbers and spaces, also place_name needs to be unique
  validates :place_name, format: { with: /[\p{L}\s\d_]+/u,
                                   message: 'Povolené znaky pro jméno prostoru jsou: 1. "_" 2. písmena 3. čísla 4. mezery' }

  validates :place_name,
            uniqueness: { message: 'Tento prostor již máme v datábázi. Patří tento prostor Vám? Napište nám na <a href="mailto:poptavka@prostormat.cz">poptavka@prostormat.cz</a>' }

  # Regexp allows for letters and spaces
  validates :street, format: { with: /[\p{L}\s]+/u, message: 'Povolené znaky pro ulici jsou písmena a mezery' }

  validates :short_description, length: { in: 10..50, message: 'Musí být alespoň 10 až 50 znaků dlouhá' }
  validates :long_description, length: { minimum: 120, message: 'Musí být alespoň 120 znaků dlouhá' }

  validates :slug, uniqueness: true
  validate :custom_validation_presence

  # This is a case insesitive query, for the search on the index page
  scope :search_by_query, lambda { |query|
    where('LOWER(city) LIKE LOWER(?) OR LOWER(street) LIKE LOWER(?) OR LOWER(place_name) LIKE LOWER(?)', "%#{query}%", "%#{query}%", "%#{query}%")
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

  def filter_ids=(ids)
    ids = ids.reject(&:blank?).map(&:to_i)
    self.filters = Filter.where(id: ids)
  end

  private

  def generate_slug
    self.slug = place_name.parameterize
  end

  def full_address_changed?
    street_changed? || house_number_changed? || postal_code_changed? || city_changed?
  end

  def expire_places_index_cache
    Rails.cache.delete('places/index')
  end

  def expire_place_show_cache
    Rails.cache.delete("place_#{slug}")
    Rails.cache.delete("place_#{slug}_address")
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
end
