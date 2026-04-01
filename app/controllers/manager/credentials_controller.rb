class Manager::CredentialsController < Manager::BaseController
  def update
    @credential = Current.account.credential || Current.account.build_credential

    if @credential.update(credential_params)
      redirect_to edit_manager_settings_path, notice: t("settings.credentials.updated")
    else
      @account = Current.account
      render "manager/settings/edit", status: :unprocessable_entity
    end
  end

  private

  def credential_params
    params.require(:credential).permit(:username, :password)
  end
end
