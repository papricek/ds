require "test_helper"

class Superadmin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create(:user, account: @account, email: "patrikjira@gmail.com", password: "password123", role: "manager")
    @other_account = create(:account, name: "Other Account")
    login_as(@superadmin)
  end

  test "index lists all accounts" do
    get superadmin_accounts_path
    assert_response :success
  end

  test "show displays account" do
    get superadmin_account_path(@other_account)
    assert_response :success
  end

  test "new renders form" do
    get new_superadmin_account_path
    assert_response :success
  end

  test "creates account" do
    assert_difference "Account.count", 1 do
      post superadmin_accounts_path, params: { account: { name: "New Account", plan: "light" } }
    end
    assert_redirected_to superadmin_account_path(Account.last)
  end

  test "edit renders form" do
    get edit_superadmin_account_path(@other_account)
    assert_response :success
  end

  test "updates account" do
    patch superadmin_account_path(@other_account), params: { account: { name: "Updated" } }
    assert_redirected_to superadmin_account_path(@other_account)
    assert_equal "Updated", @other_account.reload.name
  end

  test "destroys account" do
    assert_difference "Account.count", -1 do
      delete superadmin_account_path(@other_account)
    end
    assert_redirected_to superadmin_accounts_path
  end

  test "non-superadmin cannot access" do
    delete session_path
    regular = create(:manager, account: @account, email: "regular_mgr@example.com", password: "password123")
    login_as(regular)
    get "/superadmin/ucty"
    assert_response :not_found
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
