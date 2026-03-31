class Manager::Users::AddressesController < Manager::Users::BaseController
  before_action :set_address, only: [ :edit, :update, :destroy ]

  def index
    @addresses = @user.addresses.order(created_at: :desc)
  end

  def new
    @address = @user.addresses.build(account: Current.account)
  end

  def create
    @address = @user.addresses.build(address_params.merge(account: Current.account))
    if @address.save
      redirect_to manager_user_addresses_path(@user), notice: t("addresses.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to manager_user_addresses_path(@user), notice: t("addresses.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to manager_user_addresses_path(@user), notice: t("addresses.destroyed")
  end

  private

  def set_address
    @address = @user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:ean, :role, :street, :city, :zip, :label)
  end
end
