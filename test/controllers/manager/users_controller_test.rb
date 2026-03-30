require "test_helper"

class Manager::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manager = create(:manager, account: @account, email: "manager@example.com", password: "password123")
    @user = create(:user, account: @account)
    login_as(@manager)
  end

  test "index lists users" do
    get manager_users_path
    assert_response :success
  end

  test "show displays user" do
    get manager_user_path(@user)
    assert_response :success
  end

  test "new renders form" do
    get new_manager_user_path
    assert_response :success
  end

  test "creates user" do
    assert_difference "User.count", 1 do
      post manager_users_path, params: {
        user: { name: "New User", email: "new@example.com", phone: "123456", role: "user", password: "password123", password_confirmation: "password123" }
      }
    end
    assert_redirected_to manager_users_path
  end

  test "edit renders form" do
    get edit_manager_user_path(@user)
    assert_response :success
  end

  test "updates user" do
    patch manager_user_path(@user), params: { user: { name: "Updated Name" } }
    assert_redirected_to manager_users_path
    assert_equal "Updated Name", @user.reload.name
  end

  test "updates user without changing password when blank" do
    old_digest = @user.password_digest
    patch manager_user_path(@user), params: { user: { name: "Updated", password: "", password_confirmation: "" } }
    assert_redirected_to manager_users_path
    assert_equal old_digest, @user.reload.password_digest
  end

  test "destroys user" do
    assert_difference "User.count", -1 do
      delete manager_user_path(@user)
    end
    assert_redirected_to manager_users_path
  end

  test "regular user cannot access manager users" do
    delete session_path
    regular = create(:user, account: @account, email: "regular@example.com", password: "password123")
    login_as(regular)
    get manager_users_path
    assert_redirected_to dashboards_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
