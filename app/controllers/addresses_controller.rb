class AddressesController < AppController
  def index
    @addresses = Current.user.addresses.order(created_at: :desc)
  end
end
