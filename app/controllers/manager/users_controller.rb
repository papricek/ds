class Manager::UsersController < Manager::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = Current.account.users.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @user = Current.account.users.build
  end

  def create
    @user = Current.account.users.build(user_params)
    if @user.save
      UserMailer.welcome(@user).deliver_later
      redirect_to manager_users_path, notice: t("users.created")
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
      redirect_to manager_users_path, notice: t("users.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to manager_users_path, notice: t("users.destroyed")
  end

  private

  def set_user
    @user = Current.account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :role, :password, :password_confirmation)
  end
end
