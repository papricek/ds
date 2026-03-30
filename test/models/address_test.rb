require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "valid address" do
    address = build(:address, user: create(:user, account: @account), account: @account)
    assert address.valid?
  end

  test "requires ean" do
    address = build(:address, user: create(:user, account: @account), account: @account, ean: nil)
    assert_not address.valid?
  end

  test "ean unique within account" do
    user = create(:user, account: @account)
    create(:address, user: user, account: @account, ean: "859182400000000001")
    address = build(:address, user: user, account: @account, ean: "859182400000000001")
    assert_not address.valid?
  end

  test "customer role" do
    address = build(:address, role: "customer")
    assert address.customer?
  end

  test "supplier role" do
    address = build(:address, role: "supplier")
    assert address.supplier?
  end
end
