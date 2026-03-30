class Settings::UsersController < AppController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    update_params = user_settings_params
    update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

    if update_params[:password].present? && !@user.authenticate(params[:current_password])
      @user.errors.add(:base, t("settings.invalid_current_password"))
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(update_params)
      redirect_to edit_settings_user_path, notice: t("settings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_settings_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation)
  end
end
