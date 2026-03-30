class Manager::GroupsController < Manager::BaseController
  before_action :set_group, only: [ :show, :edit, :update, :destroy, :create_sharings ]

  def index
    @groups = Current.account.groups.order(created_at: :desc).page(params[:page])
  end

  def show
    @group_customers = @group.group_customers.includes(:group_supplier_allocations).order(:ean)
  end

  def new
    @group = Current.account.groups.build
  end

  def create
    @group = Current.account.groups.build(group_params)
    if @group.save
      redirect_to manager_group_path(@group), notice: t("groups.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to manager_group_path(@group), notice: t("groups.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to manager_groups_path, notice: t("groups.destroyed")
  end

  def create_sharings
    result = CreateSharingsFromGroup.call(@group, default_price: params[:default_price]&.to_d)
    if result.success?
      redirect_to manager_group_path(@group), notice: t("groups.sharings_created", count: result.result.size)
    else
      redirect_to manager_group_path(@group), alert: result.errors[:base]&.join(", ")
    end
  end

  private

  def set_group
    @group = Current.account.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :identifier)
  end
end
