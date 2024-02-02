class Filter < ApplicationRecord
  has_many :place_filters, dependent: :destroy
  has_many :places, through: :place_filters
end
