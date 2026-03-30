class BillingsController < AppController
  def index
    @billings = Current.user.billings.includes(:billing_items).order(created_at: :desc).page(params[:page])
  end

  def show
    @billing = Current.user.billings.find(params[:id])
    @billing_items = @billing.billing_items.includes(:sharing)
  end

  def download
    @billing = Current.user.billings.find(params[:id])
    if @billing.document.attached?
      redirect_to rails_blob_path(@billing.document, disposition: "attachment")
    else
      redirect_to billing_path(@billing), alert: t("billings.no_document")
    end
  end
end
