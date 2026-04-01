require "test_helper"

class Manager::HelpControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin, account: @account, email: "manager@example.com", password: "password123")
    login_as(@admin)
  end

  test "show renders help" do
    get manager_help_path
    assert_response :success
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
