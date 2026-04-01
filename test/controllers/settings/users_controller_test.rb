require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:account)
    @user = create(:user, account: @account, password: "password123")
    login_as(@user)
  end

  test "show renders profile form" do
    get settings_profile_path
    assert_response :success
  end

  test "updates profile" do
    patch settings_profile_path, params: { user: { name: "New Name", email: "newemail@example.com" } }
    assert_redirected_to settings_profile_path
    assert_equal "New Name", @user.reload.name
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:account)
    @user = create(:user, account: @account, password: "password123")
    login_as(@user)
  end

  test "show renders password form" do
    get settings_password_path
    assert_response :success
  end

  test "updates password with correct current password" do
    patch settings_password_path, params: { current_password: "password123", user: { password: "newpassword", password_confirmation: "newpassword" } }
    assert_redirected_to settings_password_path
  end

  test "rejects update with wrong current password" do
    patch settings_password_path, params: { current_password: "wrong", user: { password: "newpassword", password_confirmation: "newpassword" } }
    assert_response :unprocessable_entity
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
