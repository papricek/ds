require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, account: @account, email: "test@example.com", password: "password123")
  end

  test "shows login form" do
    get new_session_path
    assert_response :success
  end

  test "logs in with valid credentials" do
    post session_path, params: { email: "test@example.com", password: "password123" }
    assert_redirected_to dashboards_path
  end

  test "rejects invalid password" do
    post session_path, params: { email: "test@example.com", password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "rejects unknown email" do
    post session_path, params: { email: "unknown@example.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "logs out" do
    post session_path, params: { email: "test@example.com", password: "password123" }
    delete session_path
    assert_redirected_to new_session_path
  end
end
