class Manager::BillingsController < Manager::BaseController
  before_action :set_billing, only: [:show, :edit, :update, :destroy, :mark_paid, :download]

  def index
    @billings = Current.account.billings.includes(:user, :billing_items).order(created_at: :desc).page(params[:page])
  end

  def show
    @billing_items = @billing.billing_items.includes(:sharing)
  end

  def new
    @billing = Current.account.billings.build
  end

  def create
    user = Current.account.users.find(params[:billing][:user_id])
    result = AdminBillingCreator.call(
      account: Current.account,
      user: user,
      start_at: Date.parse(params[:billing][:start_at]),
      end_at: Date.parse(params[:billing][:end_at])
    )

    if result.success?
      redirect_to manager_billing_path(result.result), notice: t("billings.created")
    else
      @billing = Current.account.billings.build
      flash.now[:alert] = result.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @billing.update(billing_update_params)
      redirect_to manager_billing_path(@billing), notice: t("billings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @billing.destroy
    redirect_to manager_billings_path, notice: t("billings.destroyed")
  end

  def mark_paid
    @billing.paid!
    redirect_to manager_billings_path, notice: t("billings.marked_paid")
  end

  def download
    if @billing.document.attached?
      redirect_to rails_blob_path(@billing.document, disposition: "attachment")
    else
      redirect_to manager_billing_path(@billing), alert: t("billings.no_document")
    end
  end

  def batch_new
    @start_at = 1.month.ago.beginning_of_month.to_date
    @end_at = 1.month.ago.end_of_month.to_date
  end

  def batch_create
    result = BatchBillingCreator.call(
      account: Current.account,
      start_at: Date.parse(params[:start_at]),
      end_at: Date.parse(params[:end_at])
    )

    if result.success?
      data = result.result
      redirect_to manager_billings_path, notice: t("billings.batch_created", count: data[:created].size)
    else
      redirect_to batch_new_manager_billings_path, alert: result.errors.full_messages.join(", ")
    end
  end

  def export
    billings = Current.account.billings.includes(:user, :billing_items).order(created_at: :desc)
    csv = BillingsCsvExporter.call(billings)
    send_data csv, filename: "vyuctovani-#{Date.current}.csv", type: "text/csv; charset=utf-8"
  end

  private

  def set_billing
    @billing = Current.account.billings.find(params[:id])
  end

  def billing_update_params
    params.require(:billing).permit(:status, :issue_date, :due_date)
  end
end
