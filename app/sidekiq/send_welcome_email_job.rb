# frozen_string_literal: true

class SendWelcomeEmailJob < ApplicationJob
  queue_as :mailers

  def perform(user_id)
    user = User.includes(:places).find(user_id.to_i)

    UserMailer.welcome_email(user).deliver_now
  end
end
