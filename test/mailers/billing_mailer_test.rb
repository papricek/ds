require "test_helper"

class BillingMailerTest < ActionMailer::TestCase
  test "receipt_notification" do
    user = create(:user, account: create(:account))
    billing = create(:billing, account: user.account, user: user, variable_symbol: "2026000099")

    email = BillingMailer.receipt_notification(billing)
    assert_equal [user.email], email.to
    assert_includes email.subject, "2026000099"
  end
end
