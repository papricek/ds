class Manager::Users::BaseController < Manager::BaseController
  before_action :set_user

  private

  def set_user
    @user = Current.account.users.find(params[:user_id])
  end
end
