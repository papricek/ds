class AddressPolicy < ApplicationPolicy
  def index? = true
  def show? = user.admin? || record.user == user

  class Scope < Scope
    def resolve
      return scope.where(account: user.account) if user.admin?
      scope.where(user: user)
    end
  end
end
