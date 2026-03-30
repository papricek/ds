require "simple_command"

class BillingItemsCreator
  prepend SimpleCommand

  def initialize(billing)
    @billing = billing
    @user = billing.user
    @account = billing.account
  end

  def call
    active_sharings.each do |sharing|
      total_kwh = edc_shares_for(sharing).sum(:value)
      next if total_kwh.zero?

      is_supplier = sharing.from_address.user_id == @user.id
      transaction = is_supplier ? :receive : :pay

      @billing.billing_items.create!(
        sharing: sharing,
        kind: :sharings,
        transaction_type: transaction,
        amount: total_kwh,
        price: (total_kwh * (sharing.fixed_price || 0)).round(2),
        name: counterparty_name(sharing, is_supplier)
      )
    end

    @billing.billing_items
  end

  private

  def active_sharings
    user_eans = @user.addresses.pluck(:ean)
    Sharing.active.where(account: @account)
      .where("from_ean IN (?) OR to_ean IN (?)", user_eans, user_eans)
      .includes(:from_address, :to_address)
  end

  def edc_shares_for(sharing)
    Edc::Share.where(
      from_ean: sharing.from_ean,
      to_ean: sharing.to_ean,
      shared_at: @billing.start_at.beginning_of_day..@billing.end_at.end_of_day
    )
  end

  def counterparty_name(sharing, is_supplier)
    other = is_supplier ? sharing.to_address : sharing.from_address
    other&.user&.name
  end
end
