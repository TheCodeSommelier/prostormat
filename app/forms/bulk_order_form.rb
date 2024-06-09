# frozen_string_literal: true

# Bulk order form model is created for validations of bulk order form.
# Validates every field including the presence of at least one filter.
class BulkOrderForm
  include ActiveModel::Model

  attr_accessor :name, :email, :city, :min_capacity, :phone_number
  attr_reader :filter_ids

  validates :name, presence: { message: "Prosím vyplňte vaše jméno" }
  validates :email, presence: { message: "Prosím vyplňte vaše jméno" }
  validates :city, presence: { message: "Prosím vyplňte město" }
  validates :min_capacity, numericality: { only_integer: true, greater_than: 0 }, presence: { message: "Prosím vyplňte minimální kapacitu" }
  validates :filter_ids, presence: { message: "Vyberte alespoň jeden filtr prosím" }

  # Checks if the filter ids are in fact an array. If they are filters out the blank values.
  # Sets the @filter_ids to nil if the array is empty.
  def filter_ids=(value)
    @filter_ids = value.reject(&:blank?) if value.is_a?(Array)
    @filter_ids = nil if @filter_ids.blank?
  end
end
