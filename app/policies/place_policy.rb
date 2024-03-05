class PlacePolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    true
  end

  def create?
    !user.nil?
  end

  def edit?
    user.premium? && place_belongs_to_user? || user.admin?
  end

  def update?
    user.premium? && place_belongs_to_user? || user.admin?
  end

  def admin_places?
    user.admin?
  end

  private

  def place_belongs_to_user?
    record.user == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(hidden: false)
      end
    end
  end
end
