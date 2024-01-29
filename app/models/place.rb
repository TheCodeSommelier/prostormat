class Place < ApplicationRecord
  belongs_to :user
  has_many :venues, dependent: :destroy
end
