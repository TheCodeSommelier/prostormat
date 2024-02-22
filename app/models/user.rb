# frozen_string_literal: true

# User represents an individual registered on the platform with authentication handled
# by Devise. Users can own multiple places and indirectly have many venues through places.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :place
  has_one :subscription
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create do
    Stripe::Customer.create(email: email)
  end
end
