require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "valid group" do
    group = build(:group, account: @account)
    assert group.valid?
  end

  test "requires name" do
    group = build(:group, account: @account, name: nil)
    assert_not group.valid?
  end

  test "unique_sharing_pairs returns customer-supplier pairs" do
    group = create(:group, account: @account)
    gc = create(:group_customer, group: group, ean: "111111111111111111")
    create(:group_supplier_allocation, group_customer: gc, ean: "222222222222222222")
    create(:group_supplier_allocation, group_customer: gc, ean: "333333333333333333")

    pairs = group.unique_sharing_pairs
    assert_equal 2, pairs.size
    assert_includes pairs, { customer_ean: "111111111111111111", supplier_ean: "222222222222222222" }
    assert_includes pairs, { customer_ean: "111111111111111111", supplier_ean: "333333333333333333" }
  end

  test "customers_count" do
    group = create(:group, account: @account)
    create(:group_customer, group: group)
    create(:group_customer, group: group)
    assert_equal 2, group.customers_count
  end

  test "suppliers_count" do
    group = create(:group, account: @account)
    gc = create(:group_customer, group: group)
    create(:group_supplier_allocation, group_customer: gc, ean: "111111111111111111")
    create(:group_supplier_allocation, group_customer: gc, ean: "222222222222222222")
    assert_equal 2, group.suppliers_count
  end
end
