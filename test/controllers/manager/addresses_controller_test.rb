require "test_helper"

class Manager::AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin, account: @account, email: "manager@example.com", password: "password123")
    @user = create(:user, account: @account)
    @address = create(:address, user: @user, account: @account)
    login_as(@admin)
  end

  test "index lists addresses" do
    get manager_addresses_path
    assert_response :success
  end

  test "show displays address" do
    get manager_address_path(@address)
    assert_response :success
  end

  test "new renders form" do
    get new_manager_address_path
    assert_response :success
  end

  test "creates address" do
    assert_difference "Address.count", 1 do
      post manager_addresses_path, params: {
        address: { user_id: @user.id, ean: "859182400999999999", role: "customer", street: "Test 1", city: "Praha", zip: "11000" }
      }
    end
    assert_redirected_to manager_addresses_path
  end

  test "edit renders form" do
    get edit_manager_address_path(@address)
    assert_response :success
  end

  test "updates address" do
    patch manager_address_path(@address), params: { address: { label: "Updated Label" } }
    assert_redirected_to manager_addresses_path
    assert_equal "Updated Label", @address.reload.label
  end

  test "destroys address" do
    assert_difference "Address.count", -1 do
      delete manager_address_path(@address)
    end
    assert_redirected_to manager_addresses_path
  end

  test "regular user cannot access manager addresses" do
    delete session_path
    regular = create(:user, account: @account, email: "regular@example.com", password: "password123")
    login_as(regular)
    get manager_addresses_path
    assert_redirected_to dashboards_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
