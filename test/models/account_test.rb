require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "light plan by default" do
    assert @account.light?
    assert_not @account.full?
  end

  test "full plan" do
    @account.update!(plan: "full")
    assert @account.full?
    assert_not @account.light?
  end

  test "requires name" do
    account = build(:account, name: nil)
    assert_not account.valid?
  end
end
