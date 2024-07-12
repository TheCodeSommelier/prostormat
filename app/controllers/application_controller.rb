# frozen_string_literal: true

# Base controller with Devise authentication and Pundit authorization.
# - Handles overloads with redirects to overload page
# - Authenticates user before every action (Devise).
# - Enforces authorization checks on all actions except index and landing_page (Pundit).
# - Handles Pundit's NotAuthorizedError by redirecting to root_path with an alert.
class ApplicationController < ActionController::Base
  # rescue_from 'ActiveRecord::ConnectionTimeoutError', with: :render_overload_page # PostgreSQL runs out of connections
  # rescue_from 'ActionDispatch::Http::MimeNegotiation::InvalidType', with: :render_overload_page # Invalid request
  # rescue_from 'PG::ConnectionBad', with: :render_overload_page # PostgreSQL bad connection
  # rescue_from 'Rack::Timeout::RequestTimeoutError', with: :render_overload_page # Overload server
  # rescue_from 'Errno::ECONNREFUSED', with: :render_overload_page # Any app add on is not responsive

  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :meta_tags_nofollow_actions

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def verify_turnstile_token(token)
    secret_key = ENV.fetch('TURNSTILE_SECRET_KEY')
    response = Faraday.post('https://challenges.cloudflare.com/turnstile/v0/siteverify') do |req|
      req.body = {
        secret: secret_key,
        response: token
      }
    end

    result = JSON.parse(response.body)
    result['success']
  rescue StandardError => e
    Rails.logger.error("Turnstile verification failed: #{e.message}")
    false
  end

  private

  def meta_tags_nofollow_actions
    allowed_actions = %w[show index landing_page about_us faq_contact_us overload] # See if whitelist or blacklist approach
    set_meta_tags noindex: true, nofollow: true if devise_controller? || !action_name.in?(allowed_actions)
  end

  # def render_overload_page
  #   redirect_to overload_path,
  #               alert: 'Omlouváme se, ale v důsledku vysokého provozu momentálně nemůžeme zpracovat vaši žádost. Zkuste to prosím později.'
  # end
end
