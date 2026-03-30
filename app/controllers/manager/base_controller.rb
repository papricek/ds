class Manager::BaseController < AppController
  before_action :require_manager

  private

  def require_manager
    redirect_to dashboards_path, alert: t("common.not_authorized") unless Current.user.manager?
  end
end
