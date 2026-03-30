require "test_helper"

class BillingTest < ActiveSupport::TestCase
  test "valid billing" do
    user = create(:user, account: @account)
    billing = build(:billing, account: @account, user: user)
    assert billing.valid?
  end

  test "requires start_at" do
    billing = build(:billing, account: @account, start_at: nil)
    assert_not billing.valid?
  end

  test "requires end_at" do
    billing = build(:billing, account: @account, end_at: nil)
    assert_not billing.valid?
  end

  test "total_to_pay sums pay items" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    create(:billing_item, billing: billing, transaction_type: "pay", price: 100)
    create(:billing_item, billing: billing, transaction_type: "pay", price: 50)
    create(:billing_item, billing: billing, transaction_type: "receive", price: 200)
    assert_equal 150.0, billing.total_to_pay
  end

  test "total_to_receive sums receive items" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    create(:billing_item, billing: billing, transaction_type: "receive", price: 200)
    create(:billing_item, billing: billing, transaction_type: "receive", price: 100)
    assert_equal 300.0, billing.total_to_receive
  end

  test "net_amount is receive minus pay" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    create(:billing_item, billing: billing, transaction_type: "receive", price: 300)
    create(:billing_item, billing: billing, transaction_type: "pay", price: 100)
    assert_equal 200.0, billing.net_amount
  end

  test "subtotal is absolute value of net_amount" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    create(:billing_item, billing: billing, transaction_type: "pay", price: 100)
    assert_equal 100.0, billing.subtotal
  end

  test "total_kwh sums amounts" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)
    create(:billing_item, billing: billing, amount: 50)
    create(:billing_item, billing: billing, amount: 30)
    assert_equal 80.0, billing.total_kwh
  end

  test "pdf_filename uses variable symbol" do
    user = create(:user, account: @account)
    billing = build(:billing, account: @account, user: user, variable_symbol: "2026000001")
    assert_equal "doklad-2026000001.pdf", billing.pdf_filename
  end
end
