class Manager::AddressesController < Manager::BaseController
  before_action :set_address, only: [ :show, :edit, :update, :destroy ]

  def index
    @addresses = Current.account.addresses.includes(:user).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @address = Current.account.addresses.build
  end

  def create
    @address = Current.account.addresses.build(address_params)
    if @address.save
      redirect_to manager_addresses_path, notice: t("addresses.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to manager_addresses_path, notice: t("addresses.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to manager_addresses_path, notice: t("addresses.destroyed")
  end

  private

  def set_address
    @address = Current.account.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:user_id, :ean, :role, :street, :city, :zip, :label)
  end
end
