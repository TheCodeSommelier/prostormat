# frozen_string_literal: true

# User represents an individual registered on the platform with authentication handled
# by Devise. Users can own multiple places and indirectly have many venues through places.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_stripe_customer

  has_one :place, dependent: :destroy
  has_one :subscription

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private

  def create_stripe_customer
    customer = Stripe::Customer.create(email: email)
    update(stripe_customer_id: customer.id)
  end
end
