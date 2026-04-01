class Settings::AddressesController < AppController
  before_action :require_user_role
  before_action :set_address, only: [ :edit, :update, :destroy ]

  def index
    @addresses = Current.user.addresses.order(created_at: :desc)
  end

  def new
    @address = Current.user.addresses.build
  end

  def create
    @address = Current.user.addresses.build(address_params)
    @address.account = Current.account

    if @address.save
      redirect_to settings_addresses_path, notice: t("addresses.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to settings_addresses_path, notice: t("addresses.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to settings_addresses_path, notice: t("addresses.destroyed")
  end

  private

  def set_address
    @address = Current.user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:ean, :role, :label, :street, :city, :zip)
  end

  def require_user_role
    redirect_to settings_profile_path unless Current.user.user?
  end
end
