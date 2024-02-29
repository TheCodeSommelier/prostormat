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

  validates :first_name, :last_name, :company_name, :phone_number, :company_address, :ico, presence: true
  validates :phone_number, format: { with: /\A\+?(\d{1,3})?[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9}\z/ }
  validates :ico, format: { with: /\d+/ }

  private

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email: email,
      name: company_name
    )
    update(stripe_customer_id: customer.id)
  end
end
