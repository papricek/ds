require "open3"

module Edc
  class ExportService
    def self.call(account:, from_date:, to_date:, sse_ids: [], eans: [], profile: "STANDARD", calc: "MONTHLY")
      new(account: account, from_date: from_date, to_date: to_date,
          sse_ids: sse_ids, eans: eans, profile: profile, calc: calc).call
    end

    def initialize(account:, from_date:, to_date:, sse_ids: [], eans: [], profile: "STANDARD", calc: "MONTHLY")
      @account = account
      @from_date = from_date
      @to_date = to_date
      @sse_ids = sse_ids
      @eans = eans
      @profile = profile
      @calc = calc
    end

    def call
      credential = @account.credential
      unless credential&.username.present? && credential&.password.present?
        return { "status" => "error", "message" => "EDC credentials not configured for this account" }
      end

      output_path = Rails.root.join("tmp", "edc-exports", "#{@account.id}-#{@from_date}-#{@to_date}.csv").to_s
      FileUtils.mkdir_p(File.dirname(output_path))

      cmd = build_command(credential, output_path)
      stdout, stderr, status = Open3.capture3(cmd)

      if status.success?
        begin
          result = JSON.parse(stdout.lines.last.strip)
          result.merge("output_path" => output_path)
        rescue JSON::ParserError
          { "status" => "ok", "file" => output_path }
        end
      else
        error_msg = begin
          JSON.parse(stderr.lines.last.strip)["message"]
        rescue
          stderr.last(500)
        end
        { "status" => "error", "message" => error_msg }
      end
    end

    private

    def build_command(credential, output_path)
      script = Rails.root.join("lib", "edc", "export.mjs").to_s
      state_dir = Rails.root.join("tmp", "edc-session").to_s

      parts = [
        "node", script.shellescape,
        "--username", credential.username.shellescape,
        "--password", credential.password.shellescape,
        "--from", format_date(@from_date),
        "--to", format_date(@to_date),
        "--output", output_path.shellescape,
        "--profile", @profile,
        "--calc", @calc,
        "--state-dir", state_dir.shellescape
      ]

      @sse_ids.each { |id| parts.push("--sse", id.to_s) }
      @eans.each { |ean| parts.push("--ean", ean.shellescape) }

      parts.join(" ")
    end

    def format_date(date)
      date = Date.parse(date.to_s) unless date.is_a?(Date)
      date.strftime("%d.%m.%Y")
    end
  end
end
