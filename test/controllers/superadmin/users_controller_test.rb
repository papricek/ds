require "test_helper"

class Superadmin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create(:user, account: @account, email: "patrikjira@gmail.com", password: "password123", role: "admin")
    @target_account = create(:account, name: "Target Account")
    @target_user = create(:user, account: @target_account)
    login_as(@superadmin)
  end

  test "new renders user form for account" do
    get new_superadmin_account_user_path(@target_account)
    assert_response :success
  end

  test "creates user for account" do
    assert_difference "User.count", 1 do
      post superadmin_account_users_path(@target_account), params: {
        user: { name: "New User", email: "new@example.com", role: "user", password: "password123", password_confirmation: "password123" }
      }
    end
    assert_redirected_to superadmin_account_path(@target_account)
    assert_equal @target_account, User.find_by(email: "new@example.com").account
  end

  test "edit renders form" do
    get edit_superadmin_account_user_path(@target_account, @target_user)
    assert_response :success
  end

  test "updates user" do
    patch superadmin_account_user_path(@target_account, @target_user), params: { user: { name: "Updated" } }
    assert_redirected_to superadmin_account_path(@target_account)
    assert_equal "Updated", @target_user.reload.name
  end

  test "destroys user" do
    assert_difference "User.count", -1 do
      delete superadmin_account_user_path(@target_account, @target_user)
    end
    assert_redirected_to superadmin_account_path(@target_account)
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
