class Manager::GroupCustomersController < Manager::BaseController
  before_action :set_group

  def create
    @group_customer = @group.group_customers.build(group_customer_params)
    if @group_customer.save
      redirect_to manager_group_path(@group), notice: t("groups.customer_added")
    else
      redirect_to manager_group_path(@group), alert: @group_customer.errors.full_messages.join(", ")
    end
  end

  def destroy
    @group_customer = @group.group_customers.find(params[:id])
    @group_customer.destroy
    redirect_to manager_group_path(@group), notice: t("groups.customer_removed")
  end

  private

  def set_group
    @group = Current.account.groups.find(params[:group_id])
  end

  def group_customer_params
    params.require(:group_customer).permit(:ean, :valid_from, :valid_to)
  end
end
