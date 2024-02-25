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

  class Scope < Scope
    def resolve
      scope
    end
  end
end
