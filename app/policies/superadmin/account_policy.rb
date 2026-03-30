class Superadmin::AccountPolicy < ApplicationPolicy
  def index? = user.superadmin?
  def show? = user.superadmin?
  def create? = user.superadmin?
  def new? = create?
  def update? = user.superadmin?
  def edit? = update?
  def destroy? = user.superadmin?

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
