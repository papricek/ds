require "test_helper"

class BillingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, account: @account, email: "user@example.com", password: "password123")
    @billing = create(:billing, account: @account, user: @user)
    login_as(@user)
  end

  test "index shows user billings" do
    get billings_path
    assert_response :success
  end

  test "show displays billing" do
    get billing_path(@billing)
    assert_response :success
  end

  test "cannot see other users billings" do
    other_user = create(:user, account: @account)
    other_billing = create(:billing, account: @account, user: other_user)
    get billing_path(other_billing)
    assert_redirected_to dashboards_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
