# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include Transferable
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        flash.now[:alert] = resource.errors.full_messages
        respond_with resource
      end
    end

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
        format.html do
          if resource.persisted?
            redirect_to after_sign_up_path_for(resource)
          else
            render :new, alert: resource.errors.full_messages, status: :unprocessable_entity
          end
        end
      end
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up,
                                        keys: %i[first_name last_name phone_number email company_name company_address ico
                                                 password password_confirmation])
    end

    # The path used after sign up.
    def after_sign_up_path_for(_resource)
      # super(resource)
      is_free_trial_email = params[:free_trial_email] == 'true'
      p "🔥 conditions >> place_id: #{params[:place_slug]} --- is_free_trial_email: #{is_free_trial_email} --- place exists?: #{Place.exists?(slug: params[:place_slug])}"
      if params[:place_slug].present? && is_free_trial_email && Place.exists?(slug: params[:place_slug])
        @place = Place.find_by(slug: params[:place_slug])

        if transfer_place?
          if @place.free_trial_end.present? && @place.free_trial_end > Time.current
            session[:free_trial_end] =
              @place.free_trial_end
          end
          flash[:notice] = "Prostor #{@place.place_name} je převedený #{@place.user.email}"
          stripe_checkout_path
        else
          flash.now[:alert] = 'Prostor se nepodařilo převést. Zkuste to prosím znovu...'
          new_user_registration_path
        end
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
