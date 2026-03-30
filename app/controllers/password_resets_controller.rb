class PasswordResetsController < ApplicationController
  layout "application"
  skip_before_action :login_required

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user
      user.generate_password_reset_token
    end
    redirect_to new_session_path, notice: t("password_resets.email_sent")
  end

  def edit
    @token = UserToken.password_reset.valid.find_by!(token: params[:id])
    @user = @token.user
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: t("password_resets.invalid_token")
  end

  def update
    @token = UserToken.password_reset.valid.find_by!(token: params[:id])
    @user = @token.user
    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      @token.destroy
      redirect_to new_session_path, notice: t("password_resets.password_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: t("password_resets.invalid_token")
  end
end
