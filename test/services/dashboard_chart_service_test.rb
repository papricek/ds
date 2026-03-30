require "test_helper"

class DashboardChartServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, account: @account)
    @customer_address = create(:address, user: @user, account: @account, role: "customer")
    @supplier_address = create(:address, user: @user, account: @account, role: "supplier")
  end

  test "returns chart structure" do
    result = DashboardChartService.call(@user.addresses, "month")
    assert result.key?(:labels)
    assert result.key?(:consumption)
    assert result.key?(:production)
    assert result.key?(:sharing)
    assert result.key?(:totals)
  end

  test "totals include consumption production sharing" do
    result = DashboardChartService.call(@user.addresses, "month")
    assert result[:totals].key?(:consumption)
    assert result[:totals].key?(:production)
    assert result[:totals].key?(:sharing)
  end

  test "week range returns 8 days of labels" do
    result = DashboardChartService.call(@user.addresses, "week")
    assert_equal 8, result[:labels].size
  end

  test "handles empty data" do
    result = DashboardChartService.call(@user.addresses, "month")
    assert_equal 0, result[:totals][:consumption]
    assert_equal 0, result[:totals][:production]
    assert_equal 0, result[:totals][:sharing]
  end

  test "returns data arrays matching labels length" do
    result = DashboardChartService.call(@user.addresses, "month")
    assert_equal result[:labels].size, result[:consumption].size
    assert_equal result[:labels].size, result[:production].size
    assert_equal result[:labels].size, result[:sharing].size
  end
end
