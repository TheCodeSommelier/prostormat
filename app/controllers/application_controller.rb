# frozen_string_literal: true

# Base controller with Devise authentication and Pundit authorization.
# - Authenticates user before every action (Devise).
# - Enforces authorization checks on all actions except index and landing_page (Pundit).
# - Handles Pundit's NotAuthorizedError by redirecting to root_path with an alert.
class ApplicationController < ActionController::Base
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
end
