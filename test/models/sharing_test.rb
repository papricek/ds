require "test_helper"

class SharingTest < ActiveSupport::TestCase
  test "valid sharing" do
    sharing = build(:sharing, account: @account)
    assert sharing.valid?
  end

  test "sets eans from addresses" do
    supplier_address = create(:address, user: create(:user, account: @account), account: @account, role: "supplier")
    customer_address = create(:address, user: create(:user, account: @account), account: @account, role: "customer")
    sharing = Sharing.new(account: @account, from_address: supplier_address, to_address: customer_address)
    sharing.valid?
    assert_equal supplier_address.ean, sharing.from_ean
    assert_equal customer_address.ean, sharing.to_ean
  end

  test "unique from_ean and to_ean within account" do
    sharing = create(:sharing, account: @account)
    duplicate = build(:sharing, account: @account, from_address: sharing.from_address, to_address: sharing.to_address)
    assert_not duplicate.valid?
  end

  test "active scope" do
    active = create(:sharing, account: @account, status: :active)
    inactive = create(:sharing, account: @account, status: :inactive)
    assert_includes Sharing.active, active
    assert_not_includes Sharing.active, inactive
  end

  test "supplier and customer methods" do
    sharing = create(:sharing, account: @account)
    assert_equal sharing.from_address.user, sharing.supplier
    assert_equal sharing.to_address.user, sharing.customer
  end

  test "fixed_price must be non-negative" do
    sharing = build(:sharing, account: @account, fixed_price: -1)
    assert_not sharing.valid?
  end
end
