require "csv"

class BillingsCsvExporter
  def self.call(billings)
    new(billings).call
  end

  def initialize(billings)
    @billings = billings
  end

  def call
    CSV.generate(col_sep: ";", encoding: "UTF-8") do |csv|
      csv << headers
      @billings.includes(:user, :billing_items).each do |billing|
        csv << row(billing)
      end
    end
  end

  private

  def headers
    ["Variabiln\u00ED symbol", "U\u017Eivatel", "E-mail", "Obdob\u00ED od", "Obdob\u00ED do",
     "Typ", "Stav", "Vystaveno", "Splatnost", "kWh", "\u010C\u00E1stka"]
  end

  def row(billing)
    [
      billing.variable_symbol,
      billing.user.name,
      billing.user.email,
      billing.start_at&.strftime("%d.%m.%Y"),
      billing.end_at&.strftime("%d.%m.%Y"),
      I18n.t("billings.receipt"),
      I18n.t("billings.statuses.#{billing.status}"),
      billing.issue_date&.strftime("%d.%m.%Y"),
      billing.due_date&.strftime("%d.%m.%Y"),
      billing.total_kwh.round(2),
      billing.subtotal.round(2)
    ]
  end
end
