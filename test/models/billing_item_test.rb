require "test_helper"

class BillingItemTest < ActiveSupport::TestCase
  test "valid billing item" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    item = build(:billing_item, billing: billing)
    assert item.valid?
  end

  test "requires transaction_type" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    item = build(:billing_item, billing: billing, transaction_type: nil)
    assert_not item.valid?
  end

  test "receive type" do
    item = build(:billing_item, transaction_type: "receive")
    assert item.receive?
  end

  test "pay type" do
    item = build(:billing_item, transaction_type: "pay")
    assert item.pay?
  end
end
