class SessionsController < ApplicationController
  layout "application"
  skip_before_action :login_required, only: [ :new, :create ]

  def new
    redirect_to dashboards_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user.present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboards_path, notice: t("sessions.logged_in")
    else
      flash.now[:alert] = t("sessions.invalid_credentials")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    Current.user = nil
    redirect_to new_session_path, notice: t("sessions.logged_out")
  end
end
