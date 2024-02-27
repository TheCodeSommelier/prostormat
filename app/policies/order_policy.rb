class OrderPolicy < ApplicationPolicy
  def create?
    record.place.user != user
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
