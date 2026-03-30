class Manager::SharingsController < Manager::BaseController
  before_action :set_sharing, only: [:show, :edit, :update, :destroy]

  def index
    @sharings = Current.account.sharings.includes(:from_address, :to_address).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @sharing = Current.account.sharings.build(status: :active)
  end

  def create
    @sharing = Current.account.sharings.build(sharing_params)
    if @sharing.save
      redirect_to manager_sharings_path, notice: t("sharings.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @sharing.update(sharing_params)
      redirect_to manager_sharings_path, notice: t("sharings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sharing.destroy
    redirect_to manager_sharings_path, notice: t("sharings.destroyed")
  end

  private

  def set_sharing
    @sharing = Current.account.sharings.find(params[:id])
  end

  def sharing_params
    params.require(:sharing).permit(:from_address_id, :to_address_id, :status, :fixed_price)
  end
end
