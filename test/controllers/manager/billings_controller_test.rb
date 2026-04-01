require "test_helper"

class Manager::BillingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin, account: @account, email: "manager@example.com", password: "password123")
    @user = create(:user, account: @account)
    @billing = create(:billing, account: @account, user: @user)
    login_as(@admin)
  end

  test "index lists billings" do
    get manager_billings_path
    assert_response :success
  end

  test "show displays billing" do
    get manager_billing_path(@billing)
    assert_response :success
  end

  test "new renders form" do
    get new_manager_billing_path
    assert_response :success
  end

  test "edit renders form" do
    get edit_manager_billing_path(@billing)
    assert_response :success
  end

  test "marks billing as paid" do
    patch mark_paid_manager_billing_path(@billing)
    assert_redirected_to manager_billings_path
    assert @billing.reload.paid?
  end

  test "destroys billing" do
    assert_difference "Billing.count", -1 do
      delete manager_billing_path(@billing)
    end
    assert_redirected_to manager_billings_path
  end

  test "batch_new renders form" do
    get batch_new_manager_billings_path
    assert_response :success
  end

  test "export returns csv" do
    get export_manager_billings_path(format: :csv)
    assert_response :success
  end

  test "regular user cannot access" do
    delete session_path
    regular = create(:user, account: @account, email: "regular@example.com", password: "password123")
    login_as(regular)
    get manager_billings_path
    assert_redirected_to dashboards_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
