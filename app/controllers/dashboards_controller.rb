class DashboardsController < AppController
  def index
    @date_range = params[:range].presence || "month"
    @addresses = scoped_addresses
    @chart_data = DashboardChartService.call(@addresses, @date_range)
  end

  private

  def scoped_addresses
    if Current.user.admin?
      Current.account.addresses
    else
      Current.user.addresses
    end
  end
end
