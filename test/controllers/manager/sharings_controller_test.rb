require "test_helper"

class Manager::SharingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manager = create(:manager, account: @account, email: "manager@example.com", password: "password123")
    @sharing = create(:sharing, account: @account)
    login_as(@manager)
  end

  test "index lists sharings" do
    get manager_sharings_path
    assert_response :success
  end

  test "show displays sharing" do
    get manager_sharing_path(@sharing)
    assert_response :success
  end

  test "new renders form" do
    create(:address, account: @account, role: "supplier", user: create(:user, account: @account))
    create(:address, account: @account, role: "customer", user: create(:user, account: @account))
    get new_manager_sharing_path
    assert_response :success
  end

  test "creates sharing" do
    supplier = create(:address, account: @account, role: "supplier", user: create(:user, account: @account))
    customer = create(:address, account: @account, role: "customer", user: create(:user, account: @account))
    assert_difference "Sharing.count", 1 do
      post manager_sharings_path, params: {
        sharing: { from_address_id: supplier.id, to_address_id: customer.id, status: "active", fixed_price: 2.0 }
      }
    end
    assert_redirected_to manager_sharings_path
  end

  test "updates sharing" do
    patch manager_sharing_path(@sharing), params: { sharing: { fixed_price: 5.0 } }
    assert_redirected_to manager_sharings_path
    assert_equal 5.0, @sharing.reload.fixed_price.to_f
  end

  test "destroys sharing" do
    assert_difference "Sharing.count", -1 do
      delete manager_sharing_path(@sharing)
    end
    assert_redirected_to manager_sharings_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
