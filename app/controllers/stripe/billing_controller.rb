# frozen_string_literal: true

module Stripe
  class BillingController < ApplicationController
    def create
      session = Stripe::BillingPortal::Session.create({
                                                        customer: current_user.stripe_customer_id,
                                                        return_url: root_url
                                                      })
      redirect_to session.url, allow_other_host: true
    end
  end
end
