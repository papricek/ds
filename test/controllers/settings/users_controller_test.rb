require "test_helper"

class Settings::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, account: @account, email: "user@example.com", password: "password123")
    login_as(@user)
  end

  test "edit renders profile form" do
    get edit_settings_user_path
    assert_response :success
  end

  test "updates profile" do
    patch settings_user_path, params: { user: { name: "New Name", email: "newemail@example.com" } }
    assert_redirected_to edit_settings_user_path
    assert_equal "New Name", @user.reload.name
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
