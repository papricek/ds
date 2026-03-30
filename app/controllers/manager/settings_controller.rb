class Manager::SettingsController < Manager::BaseController
  def edit
    @account = Current.account
    @credential = @account.credential || @account.build_credential
  end

  def update
    @account = Current.account

    if @account.update(account_params)
      redirect_to edit_manager_settings_path, notice: t("settings.updated")
    else
      @credential = @account.credential || @account.build_credential
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :logo,
      :settings_issue_day_in_month, :settings_supply_day_in_month,
      :settings_due_days, :settings_billing_copy_email)
  end
end
