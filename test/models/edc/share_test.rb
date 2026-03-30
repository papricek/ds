require "test_helper"

class Edc::ShareTest < ActiveSupport::TestCase
  test "valid share" do
    share = build(:edc_share)
    assert share.valid?
  end

  test "requires from_ean" do
    share = build(:edc_share, from_ean: nil)
    assert_not share.valid?
  end

  test "requires to_ean" do
    share = build(:edc_share, to_ean: nil)
    assert_not share.valid?
  end

  test "requires value" do
    share = build(:edc_share, value: nil)
    assert_not share.valid?
  end

  test "requires shared_at" do
    share = build(:edc_share, shared_at: nil)
    assert_not share.valid?
  end

  test "unique constraint on from_ean, to_ean, shared_at" do
    shared_at = Time.current
    create(:edc_share, from_ean: "111", to_ean: "222", shared_at: shared_at)
    duplicate = build(:edc_share, from_ean: "111", to_ean: "222", shared_at: shared_at)
    assert_not duplicate.valid?
  end

  test "for_sharing scope" do
    sharing = create(:sharing, account: @account)
    share = create(:edc_share, from_ean: sharing.from_ean, to_ean: sharing.to_ean)
    other = create(:edc_share, from_ean: "999", to_ean: "888")

    result = Edc::Share.for_sharing(sharing)
    assert_includes result, share
    assert_not_includes result, other
  end

  test "in_period scope" do
    old_share = create(:edc_share, shared_at: 60.days.ago)
    recent_share = create(:edc_share, shared_at: 5.days.ago)

    result = Edc::Share.in_period(10.days.ago, Date.current)
    assert_includes result, recent_share
    assert_not_includes result, old_share
  end
end
