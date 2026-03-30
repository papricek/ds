require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, account: @account, email: "user@example.com", password: "password123")
    @address = create(:address, user: @user, account: @account)
    login_as(@user)
  end

  test "index shows user addresses" do
    get addresses_path
    assert_response :success
  end

  test "unauthenticated user redirected to login" do
    delete session_path
    get addresses_path
    assert_redirected_to new_session_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
