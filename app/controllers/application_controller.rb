class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception

  before_action :set_currents
  before_action :login_required

  helper_method :current_user, :logged_in?, :impersonated?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def set_currents
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    Current.account = Current.user&.account
    Current.impersonated = session[:original_user_id].present?
  end

  def logged_in?
    Current.user.present?
  end

  def current_user
    Current.user
  end

  def login_required
    redirect_to new_session_path, alert: t("common.login_required") unless logged_in?
  end

  def user_not_authorized
    flash[:alert] = t("common.not_authorized")
    redirect_back fallback_location: dashboards_path
  end

  def record_not_found
    redirect_to dashboards_path, alert: t("common.not_found")
  end

  def impersonated?
    session[:original_user_id].present?
  end
end
