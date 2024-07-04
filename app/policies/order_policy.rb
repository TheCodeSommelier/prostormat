# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
