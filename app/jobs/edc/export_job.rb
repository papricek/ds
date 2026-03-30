module Edc
  class ExportJob < ApplicationJob
    queue_as :default

    def perform(account_id, from_date, to_date, options = {})
      account = Account.find(account_id)
      result = Edc::ExportService.call(
        account: account,
        from_date: from_date,
        to_date: to_date,
        sse_ids: options[:sse_ids] || [],
        eans: options[:eans] || [],
        profile: options[:profile] || "STANDARD",
        calc: options[:calc] || "MONTHLY"
      )

      if result["status"] == "ok" && File.exist?(result["file"] || result["output_path"] || "")
        Rails.logger.info("EDC export completed for account #{account_id}: #{result['file'] || result['output_path']}")
      else
        Rails.logger.error("EDC export failed for account #{account_id}: #{result['message']}")
      end
    end
  end
end
