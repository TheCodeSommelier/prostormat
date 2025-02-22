# frozen_string_literal: true

# Order represents a transaction between a Bokee and a Venue where an event
# type is booked. It belongs to both a Bokee and a Venue.
class Order < ApplicationRecord
  belongs_to :bokee
  belongs_to :place
  accepts_nested_attributes_for :bokee

  validates :event_type, presence: { message: 'Druh eventu nesmí být prázdný' }
  validates :date, presence: { message: 'Datum nesmí být prázdné' }
  validate :date_cannot_be_in_the_past

  private

  def date_cannot_be_in_the_past
    errors.add(:date, 'Vyberte datum, které není v minulosti!') if date.present? && date < Date.today
  end
end
