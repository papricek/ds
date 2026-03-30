class Superadmin::UsersController < Superadmin::BaseController
  before_action :set_account
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def new
    @user = @account.users.build
  end

  def create
    @user = @account.users.build(user_params)
    if @user.save
      UserMailer.welcome(@user).deliver_later
      redirect_to superadmin_account_path(@account), notice: t("superadmin.users.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = user_params
    update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?
    if @user.update(update_params)
      redirect_to superadmin_account_path(@account), notice: t("superadmin.users.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to superadmin_account_path(@account), notice: t("superadmin.users.destroyed")
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_user
    @user = @account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :role, :password, :password_confirmation)
  end
end
