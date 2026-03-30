require "simple_command"

class BatchBillingCreator
  prepend SimpleCommand

  def initialize(account:, start_at:, end_at:)
    @account = account
    @start_at = start_at
    @end_at = end_at
  end

  def call
    created = []
    failed = []

    users_with_sharings.each do |user|
      result = AdminBillingCreator.call(
        account: @account,
        user: user,
        start_at: @start_at,
        end_at: @end_at
      )

      if result.success?
        created << result.result
      else
        failed << { user: user, errors: result.errors.full_messages }
      end
    end

    { created: created, failed: failed }
  end

  private

  def users_with_sharings
    eans = @account.addresses.pluck(:ean)
    sharing_eans = Sharing.active.where(account: @account)
      .pluck(:from_ean, :to_ean).flatten.uniq

    active_eans = eans & sharing_eans
    user_ids = @account.addresses.where(ean: active_eans).pluck(:user_id).uniq
    @account.users.where(id: user_ids)
  end
end
