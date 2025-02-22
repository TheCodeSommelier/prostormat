# frozen_string_literal: true

# Bulk order form model is created for validations of bulk order form.
# Validates every field including the presence of at least one filter.
class BulkOrderForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :city, :min_capacity, :phone_number, :date, :message
  attr_reader :filter_ids

  validates :min_capacity, numericality: { only_integer: true, greater_than: 0 },
                           presence: { message: 'Prosím vyplňte minimální kapacitu' }
end
