require "test_helper"

class Edc::ExportServiceTest < ActiveSupport::TestCase
  test "returns error when credentials not configured" do
    result = Edc::ExportService.call(
      account: @account,
      from_date: 1.month.ago.beginning_of_month.to_date,
      to_date: 1.month.ago.end_of_month.to_date
    )
    assert_equal "error", result["status"]
    assert_equal "EDC credentials not configured for this account", result["message"]
  end

  test "builds correct command with sse ids" do
    credential = OpenStruct.new(username: "test@example.com", password: "pass123")
    service = Edc::ExportService.new(
      account: @account,
      from_date: Date.new(2026, 2, 1),
      to_date: Date.new(2026, 2, 28),
      sse_ids: [37183]
    )

    cmd = service.send(:build_command, credential, "/tmp/test.csv")
    assert_includes cmd, "export.mjs"
    assert_includes cmd, "--username"
    assert_includes cmd, "--from"
    assert_includes cmd, "01.02.2026"
    assert_includes cmd, "--to"
    assert_includes cmd, "28.02.2026"
    assert_includes cmd, "--sse"
    assert_includes cmd, "37183"
    assert_includes cmd, "--state-dir"
  end

  test "builds correct command with ean list" do
    credential = OpenStruct.new(username: "test@example.com", password: "pass123")
    service = Edc::ExportService.new(
      account: @account,
      from_date: Date.new(2026, 3, 1),
      to_date: Date.new(2026, 3, 31),
      eans: ["859182400221248415", "859182400221248416"]
    )

    cmd = service.send(:build_command, credential, "/tmp/test.csv")
    assert_includes cmd, "--ean"
    assert_includes cmd, "859182400221248415"
    assert_includes cmd, "859182400221248416"
  end

  test "formats date correctly" do
    service = Edc::ExportService.new(
      account: @account,
      from_date: Date.new(2026, 1, 5),
      to_date: Date.new(2026, 12, 31)
    )
    assert_equal "05.01.2026", service.send(:format_date, Date.new(2026, 1, 5))
    assert_equal "31.12.2026", service.send(:format_date, Date.new(2026, 12, 31))
  end

  test "formats string date correctly" do
    service = Edc::ExportService.new(
      account: @account,
      from_date: "2026-03-01",
      to_date: "2026-03-31"
    )
    assert_equal "01.03.2026", service.send(:format_date, "2026-03-01")
  end
end
