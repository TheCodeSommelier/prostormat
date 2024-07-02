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

  before_action :authenticate_user!
  include Pundit::Authorization

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

  # private

  # def render_overload_page
  #   redirect_to overload_path,
  #               alert: 'Omlouváme se, ale v důsledku vysokého provozu momentálně nemůžeme zpracovat vaši žádost. Zkuste to prosím později.'
  # end
end
