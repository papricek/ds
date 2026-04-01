require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, account: @account, email: "user@example.com", password: "password123")
    login_as(@user)
  end

  test "index renders dashboard" do
    get dashboards_path
    assert_response :success
  end

  test "index with week range" do
    get dashboards_path(range: "week")
    assert_response :success
  end

  test "index with quarter range" do
    get dashboards_path(range: "quarter")
    assert_response :success
  end

  test "admin sees account-wide data" do
    delete session_path
    admin = create(:admin, account: @account, email: "admin@example.com", password: "password123")
    login_as(admin)
    get dashboards_path
    assert_response :success
  end

  test "unauthenticated redirects to login" do
    delete session_path
    get dashboards_path
    assert_redirected_to new_session_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
