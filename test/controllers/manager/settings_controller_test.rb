require "test_helper"

class Manager::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin, account: @account, email: "manager@example.com", password: "password123")
    login_as(@admin)
  end

  test "edit renders settings" do
    get edit_manager_settings_path
    assert_response :success
  end

  test "updates account settings" do
    patch manager_settings_path, params: { account: { name: "New Name", settings_due_days: "21" } }
    assert_redirected_to edit_manager_settings_path
    assert_equal "New Name", @account.reload.name
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
