class Manager::Users::SharingsController < Manager::Users::BaseController
  def show
    user_eans = @user.addresses.pluck(:ean)
    @sharings = Current.account.sharings
      .where("from_ean IN (?) OR to_ean IN (?)", user_eans, user_eans)
      .includes(:from_address, :to_address)
      .order(created_at: :desc)
  end
end
