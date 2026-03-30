class Superadmin::AccountsController < Superadmin::BaseController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]

  def index
    @accounts = Account.order(created_at: :desc).page(params[:page])
  end

  def show
    @users = @account.users.order(created_at: :desc)
    @addresses = @account.addresses.includes(:user).order(created_at: :desc).limit(20)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to superadmin_account_path(@account), notice: t("superadmin.accounts.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to superadmin_account_path(@account), notice: t("superadmin.accounts.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to superadmin_accounts_path, notice: t("superadmin.accounts.destroyed")
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :subdomain, :plan, :logo,
      :settings_issue_day_in_month, :settings_supply_day_in_month,
      :settings_due_days, :settings_billing_copy_email)
  end
end
