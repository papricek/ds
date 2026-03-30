require "test_helper"

class BillingVariableSymbolGeneratorTest < ActiveSupport::TestCase
  test "generates symbol with year prefix" do
    user = create(:user, account: @account)
    billing = create(:billing, account: @account, user: user, variable_symbol: nil, issue_date: Date.current)
    symbol = BillingVariableSymbolGenerator.call(billing)
    assert symbol.start_with?(Date.current.year.to_s)
    assert_equal 10, symbol.length
  end

  test "increments sequence" do
    user = create(:user, account: @account)
    create(:billing, account: @account, user: user, variable_symbol: "2026000001")
    billing2 = build(:billing, account: @account, user: user, variable_symbol: nil, issue_date: Date.current)
    symbol = BillingVariableSymbolGenerator.call(billing2)
    assert_equal "2026000002", symbol
  end
end
