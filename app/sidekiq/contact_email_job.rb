# frozen_string_literal: true

class ContactEmailJob < ApplicationJob
  queue_as :mailers

  def perform(contact_form_params)
    UserMailer.contact_us_email(contact_form_params).deliver_now
  end
end
