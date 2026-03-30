require "test_helper"

class Edc::ReadingTest < ActiveSupport::TestCase
  test "valid reading" do
    reading = build(:edc_reading)
    assert reading.valid?
  end

  test "requires ean" do
    reading = build(:edc_reading, ean: nil)
    assert_not reading.valid?
  end

  test "requires shared_at" do
    reading = build(:edc_reading, shared_at: nil)
    assert_not reading.valid?
  end

  test "unique constraint on ean and shared_at" do
    shared_at = Time.current
    create(:edc_reading, ean: "111", shared_at: shared_at)
    duplicate = build(:edc_reading, ean: "111", shared_at: shared_at)
    assert_not duplicate.valid?
  end

  test "in_period scope" do
    old = create(:edc_reading, shared_at: 60.days.ago)
    recent = create(:edc_reading, shared_at: 5.days.ago)

    result = Edc::Reading.in_period(10.days.ago, Date.current)
    assert_includes result, recent
    assert_not_includes result, old
  end
end
