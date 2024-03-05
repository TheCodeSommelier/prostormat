class PlacePolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    user.admin? || user.places.count < 1
  end

  def create?
    !user.nil? && user.admin? || user.places.count < 1
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
      if user.nil? || !user.admin?
        scope.where(hidden: false)
      elsif user.admin?
        scope.all
      end
    end
  end
end
