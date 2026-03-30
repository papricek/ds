class Manager::GroupSupplierAllocationsController < Manager::BaseController
  before_action :set_group_and_customer

  def create
    @allocation = @group_customer.group_supplier_allocations.build(allocation_params)
    if @allocation.save
      redirect_to manager_group_path(@group), notice: t("groups.allocation_added")
    else
      redirect_to manager_group_path(@group), alert: @allocation.errors.full_messages.join(", ")
    end
  end

  def destroy
    @allocation = @group_customer.group_supplier_allocations.find(params[:id])
    @allocation.destroy
    redirect_to manager_group_path(@group), notice: t("groups.allocation_removed")
  end

  private

  def set_group_and_customer
    @group = Current.account.groups.find(params[:group_id])
    @group_customer = @group.group_customers.find(params[:group_customer_id])
  end

  def allocation_params
    params.require(:group_supplier_allocation).permit(:ean, :allocation_ratio, :allocation_order)
  end
end
