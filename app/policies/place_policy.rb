class PlacePolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
