class Manager::BaseController < AppController
  before_action :require_admin

  private

  def require_admin
    redirect_to dashboards_path, alert: t("common.not_authorized") unless Current.user.admin? || Current.user.superadmin?
  end
end
