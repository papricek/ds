class Superadmin::UserPolicy < ApplicationPolicy
  def create? = user.superadmin?
  def new? = create?
  def update? = user.superadmin?
  def edit? = update?
  def destroy? = user.superadmin?
end
