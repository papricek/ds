class Superadmin::BaseController < AppController
  before_action :require_superadmin

  private

  def require_superadmin
    redirect_to dashboards_path, alert: t("common.not_authorized") unless Current.user.superadmin?
  end
end
