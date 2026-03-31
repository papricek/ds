class SharingsController < AppController
  def index
    user_eans = Current.user.addresses.pluck(:ean)
    @sharings = Current.account.sharings
      .where("from_ean IN (?) OR to_ean IN (?)", user_eans, user_eans)
      .includes(:from_address, :to_address)
      .order(created_at: :desc)
  end
end
