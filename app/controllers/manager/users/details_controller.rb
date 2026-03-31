class Manager::Users::DetailsController < Manager::Users::BaseController
  def show
  end

  def update
    update_params = user_params
    update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?
    if @user.update(update_params)
      redirect_to manager_user_details_path(@user), notice: t("users.updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone, :role, :password, :password_confirmation)
  end
end
