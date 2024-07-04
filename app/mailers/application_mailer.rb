# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'poptavka@prostormat.cz'
  layout 'mailer'
end
