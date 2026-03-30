require "test_helper"

class BillingItemsCreatorTest < ActiveSupport::TestCase
  setup do
    @supplier_user = create(:user, account: @account)
    @customer_user = create(:user, account: @account)
    @supplier_address = create(:address, user: @supplier_user, account: @account, role: "supplier")
    @customer_address = create(:address, user: @customer_user, account: @account, role: "customer")
    @sharing = create(:sharing,
      account: @account,
      from_address: @supplier_address,
      to_address: @customer_address,
      fixed_price: 2.50,
      status: :active
    )
  end

  test "creates billing items from EDC shares for customer" do
    create(:edc_share,
      from_ean: @sharing.from_ean,
      to_ean: @sharing.to_ean,
      value: 10.0,
      shared_at: 15.days.ago
    )

    billing = create(:billing, account: @account, user: @customer_user,
      start_at: 1.month.ago.to_date, end_at: Date.current)

    result = BillingItemsCreator.call(billing)
    assert result.success?
    assert_equal 1, billing.billing_items.count

    item = billing.billing_items.first
    assert item.pay?
    assert_equal 10.0, item.amount
    assert_equal 25.0, item.price
  end

  test "creates receive items for supplier" do
    create(:edc_share,
      from_ean: @sharing.from_ean,
      to_ean: @sharing.to_ean,
      value: 10.0,
      shared_at: 15.days.ago
    )

    billing = create(:billing, account: @account, user: @supplier_user,
      start_at: 1.month.ago.to_date, end_at: Date.current)

    result = BillingItemsCreator.call(billing)
    assert result.success?

    item = billing.billing_items.first
    assert item.receive?
  end

  test "skips sharings with zero kwh" do
    billing = create(:billing, account: @account, user: @customer_user,
      start_at: 1.month.ago.to_date, end_at: Date.current)

    result = BillingItemsCreator.call(billing)
    assert result.success?
    assert_equal 0, billing.billing_items.count
  end

  test "only includes shares within billing period" do
    create(:edc_share, from_ean: @sharing.from_ean, to_ean: @sharing.to_ean,
      value: 10.0, shared_at: 15.days.ago)
    create(:edc_share, from_ean: @sharing.from_ean, to_ean: @sharing.to_ean,
      value: 5.0, shared_at: 60.days.ago)

    billing = create(:billing, account: @account, user: @customer_user,
      start_at: 1.month.ago.to_date, end_at: Date.current)

    BillingItemsCreator.call(billing)
    assert_equal 10.0, billing.billing_items.first.amount
  end
end
