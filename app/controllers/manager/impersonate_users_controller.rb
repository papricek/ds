class Manager::ImpersonateUsersController < Manager::BaseController
  skip_before_action :require_manager, only: :destroy

  def update
    user = Current.account.users.find(params[:id])
    authorize [:manager, user], :impersonate?

    session[:original_user_id] = session[:user_id]
    session[:user_id] = user.id

    redirect_to dashboards_path, notice: t("manager.impersonate.started", email: user.email)
  end

  def destroy
    session[:user_id] = session[:original_user_id]
    session.delete(:original_user_id)

    redirect_to manager_users_path, notice: t("manager.impersonate.stopped")
  end
end
