class BillingVariableSymbolGenerator
  def self.call(billing)
    new(billing).call
  end

  def initialize(billing)
    @billing = billing
  end

  def call
    year = @billing.issue_date&.year || Date.current.year
    sequence = next_sequence(year)
    "#{year}#{format('%06d', sequence)}"
  end

  private

  def next_sequence(year)
    last = Billing.where(account: @billing.account)
      .where("variable_symbol LIKE ?", "#{year}%")
      .order(variable_symbol: :desc)
      .pick(:variable_symbol)

    if last
      last[-6..].to_i + 1
    else
      1
    end
  end
end
