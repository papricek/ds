class Manager::BillingPolicy < ApplicationPolicy
  def index? = user.admin?
  def show? = user.admin? && record.account == user.account
  def create? = user.admin?
  def new? = create?
  def update? = user.admin? && record.account == user.account
  def edit? = update?
  def destroy? = user.admin? && record.account == user.account
  def mark_paid? = user.admin? && record.account == user.account
  def download? = user.admin? && record.account == user.account
  def batch_new? = user.admin?
  def batch_create? = user.admin?
  def export? = user.admin?

  class Scope < Scope
    def resolve
      scope.where(account: user.account)
    end
  end
end
