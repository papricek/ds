require "test_helper"

class CreateSharingsFromGroupTest < ActiveSupport::TestCase
  setup do
    @supplier_user = create(:user, account: @account)
    @customer_user = create(:user, account: @account)
    @supplier_address = create(:address, user: @supplier_user, account: @account, role: "supplier", ean: "111111111111111111")
    @customer_address = create(:address, user: @customer_user, account: @account, role: "customer", ean: "222222222222222222")

    @group = create(:group, account: @account)
    gc = create(:group_customer, group: @group, ean: "222222222222222222")
    create(:group_supplier_allocation, group_customer: gc, ean: "111111111111111111")
  end

  test "creates sharings from group pairs" do
    result = CreateSharingsFromGroup.call(@group)
    assert result.success?
    assert_equal 1, result.result.size

    sharing = result.result.first
    assert_equal "111111111111111111", sharing.from_ean
    assert_equal "222222222222222222", sharing.to_ean
    assert sharing.active?
  end

  test "sets default price" do
    result = CreateSharingsFromGroup.call(@group, default_price: 3.50)
    assert result.success?
    assert_equal 3.50, result.result.first.fixed_price.to_f
  end

  test "skips pairs without matching addresses" do
    gc2 = create(:group_customer, group: @group, ean: "999999999999999999")
    create(:group_supplier_allocation, group_customer: gc2, ean: "888888888888888888")

    result = CreateSharingsFromGroup.call(@group)
    assert result.success?
    assert_equal 1, result.result.size
  end

  test "does not duplicate existing sharings" do
    CreateSharingsFromGroup.call(@group)
    result = CreateSharingsFromGroup.call(@group)
    assert result.success?
    assert_equal 0, result.result.size
    assert_equal 1, Sharing.count
  end
end
