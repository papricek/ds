require "test_helper"

class BillingsCsvExporterTest < ActiveSupport::TestCase
  test "exports CSV with billing data" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user, variable_symbol: "2026000001")
    create(:billing_item, billing: billing, amount: 100, price: 250)

    csv = BillingsCsvExporter.call(Billing.where(id: billing.id))
    assert csv.include?("2026000001")
    assert csv.include?(user.name)
  end

  test "uses semicolon separator" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user)

    csv = BillingsCsvExporter.call(Billing.where(id: billing.id))
    assert csv.include?(";")
  end
end
