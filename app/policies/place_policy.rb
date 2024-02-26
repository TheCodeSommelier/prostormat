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
    user.premium? && place_belongs_to_user?
  end

  def update?
    user.premium? && place_belongs_to_user?
  end

  private

  def place_belongs_to_user?
    record.user == user
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
