class Manager::UserPolicy < ApplicationPolicy
  def index? = user.manager?
  def show? = user.manager? && same_account?
  def create? = user.manager?
  def new? = create?
  def update? = user.manager? && same_account?
  def edit? = update?
  def destroy? = user.manager? && same_account? && record != user

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
