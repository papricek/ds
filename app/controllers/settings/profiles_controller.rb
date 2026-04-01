class Settings::ProfilesController < AppController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: t("settings.updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :phone)
  end
end
