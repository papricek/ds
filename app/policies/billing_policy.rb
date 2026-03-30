class BillingPolicy < ApplicationPolicy
  def index? = true

  def show?
    user.manager? || record.user == user
  end

  def download?
    show?
  end

  class Scope < Scope
    def resolve
      return scope.where(account: user.account) if user.manager?
      scope.where(user: user)
    end
  end
end
