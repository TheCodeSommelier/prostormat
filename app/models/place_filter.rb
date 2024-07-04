# frozen_string_literal: true

class PlaceFilter < ApplicationRecord
  belongs_to :place
  belongs_to :filter
end
