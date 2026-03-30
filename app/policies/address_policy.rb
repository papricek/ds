class AddressPolicy < ApplicationPolicy
  def index? = true
  def show? = user.manager? || record.user == user

  class Scope < Scope
    def resolve
      return scope.where(account: user.account) if user.manager?
      scope.where(user: user)
    end
  end
end
