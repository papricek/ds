class Manager::Users::BillingsController < Manager::Users::BaseController
  def show
    @billings = @user.billings.includes(:billing_items).order(created_at: :desc)
  end
end
