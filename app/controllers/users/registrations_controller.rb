# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    def respond_with(resource, _opts = {})
      respond_to do |format|
        format.json do
          if resource.persisted?
            render json: { redirect_url: after_sign_up_path_for(resource) }
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end
        format.html { super }
      end
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up,
                                        keys: %i[first_name last_name phone_number email company_name company_address ico
                                                 password password_confirmation])
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    def after_sign_up_path_for(_resource)
      # super(resource)
      p "🔥 params place_id #{params[:place_id].present?} --- free trial #{params[:free_trial_email] == 'true'} --- place exists #{Place.exists?(params[:place_id])}"
      p "🔥 params place_id #{params[:place_id]} --- free trial #{params[:free_trial_email]}"
      if params[:place_id].present? && params[:free_trial_email] == 'true' && Place.exists?(params[:place_id])
        root_path
      else
        new_place_path
      end
    end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
