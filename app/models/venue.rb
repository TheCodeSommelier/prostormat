class Venue < ApplicationRecord
  belongs_to :place
  has_many :orders
  has_many :bokees, through: :orders
end
