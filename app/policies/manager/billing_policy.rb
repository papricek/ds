class Manager::BillingPolicy < ApplicationPolicy
  def index? = user.manager?
  def show? = user.manager? && record.account == user.account
  def create? = user.manager?
  def new? = create?
  def update? = user.manager? && record.account == user.account
  def edit? = update?
  def destroy? = user.manager? && record.account == user.account
  def mark_paid? = user.manager? && record.account == user.account
  def download? = user.manager? && record.account == user.account
  def batch_new? = user.manager?
  def batch_create? = user.manager?
  def export? = user.manager?

  class Scope < Scope
    def resolve
      scope.where(account: user.account)
    end
  end
end
