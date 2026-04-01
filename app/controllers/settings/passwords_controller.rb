class Settings::PasswordsController < AppController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    unless @user.authenticate(params[:current_password])
      @user.errors.add(:base, t("settings.invalid_current_password"))
      render :show, status: :unprocessable_entity
      return
    end

    if @user.update(password_params)
      redirect_to settings_password_path, notice: t("settings.password_updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
