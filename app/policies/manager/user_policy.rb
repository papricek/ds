class Manager::UserPolicy < ApplicationPolicy
  def index? = user.admin?
  def show? = user.admin? && same_account?
  def create? = user.admin?
  def new? = create?
  def update? = user.admin? && same_account?
  def edit? = update?
  def destroy? = user.admin? && same_account? && record != user
  def impersonate? = user.admin? && same_account? && record != user

  class Scope < Scope
    def resolve
      scope.where(account: user.account)
    end
  end

  private

  def same_account?
    record.account == user.account
  end
end
