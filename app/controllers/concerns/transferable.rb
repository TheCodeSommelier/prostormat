module Transferable
  extend ActiveSupport::Concern

  included do
    before_action :set_transferable_place, only: [:transfer]
  end

  def transfer_place?
    other_user = User.find_by(email: transfer_params[:user_email]) || User.find_by(email: sign_up_params[:email])

    if other_user
      hidden_status = other_user.premium ? false : true
      @place.update_columns(user_id: other_user.id, hidden: hidden_status, updated_at: DateTime.now,
                            owner_email: other_user.email)
      true
    else
      false
    end
  end

  private

  def set_transferable_place
    @place = Place.find_by(slug: params[:slug])
  end

  def transfer_params
    params.permit(:user_email)
  end
end
