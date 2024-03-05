# frozen_string_literal: true

# User represents an individual registered on the platform with authentication handled
# by Devise. Users can own multiple places and indirectly have many venues through places.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_stripe_customer

  has_many :places, dependent: :destroy
  has_one :subscription

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :company_name, :phone_number, :company_address, :ico, presence: true
  validates :phone_number,
            format: { with: /\A\+?(\d{1,3})?[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9}\z/,
                      message: 'Zadejte své telefonní číslo ve standardním mezinárodním formátu, s možným předčíslím (+), kódem oblasti a číslem. Oddělte části čísla mezerami. Například: +420 123 456 789.'
            }
  validates :ico, format: { with: /\d+/, message: 'IČO musí být pouze čísla' }
  validates :company_address, format: { with: /\A[\p{L}\s]+\s\d+,\s?\d{3}\s?\d{2},\s?[\p{L}\s\d]+\z/u, message: 'Adresa firmy musí být formátována takto: ulice, PSČ, Město' }

  validate :validate_user_places_limit, on: :create

  private

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email:,
      name: company_name
    )
    update(stripe_customer_id: customer.id)
  end

  def validate_user_places_limit
    errors.add(:user, 'může mít pouze jeden prostor.') if !user.admin? && user.places.count >= 1
  end
end
