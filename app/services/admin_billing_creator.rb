require "simple_command"

class AdminBillingCreator
  prepend SimpleCommand

  def initialize(account:, user:, start_at:, end_at:)
    @account = account
    @user = user
    @start_at = start_at
    @end_at = end_at
  end

  def call
    billing = @account.billings.create!(
      user: @user,
      kind: :receipt,
      status: :active,
      period: "monthly",
      start_at: @start_at,
      end_at: @end_at,
      issue_date: issue_date,
      supply_date: @end_at,
      due_date: due_date
    )

    billing.update!(variable_symbol: BillingVariableSymbolGenerator.call(billing))

    items_result = BillingItemsCreator.call(billing)
    unless items_result.success?
      errors.add(:base, items_result.errors.full_messages.join(", "))
    end

    billing
  end

  private

  def issue_date
    day = @account.settings_issue_day_in_month.presence&.to_i || Date.current.day
    Date.new(Date.current.year, Date.current.month, [ day, 28 ].min)
  rescue ArgumentError
    Date.current
  end

  def due_date
    days = @account.settings_due_days.presence&.to_i || 14
    issue_date + days.days
  end
end
