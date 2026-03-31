class ContactFormsController < ApplicationController
  skip_before_action :login_required

  layout false

  def new
    @contact_form = ContactForm.new
    session[:contact_form_timestamp] = Time.current.to_i
  end

  def create
    if spam?
      head :ok
      return
    end

    @contact_form = ContactForm.new(contact_form_params)

    if @contact_form.save
      ContactFormMailer.notify_admin(@contact_form).deliver_later
      flash[:notice] = t("contact_forms.create.notice_success")
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:name, :email, :phone, :message)
  end

  def spam?
    return true if params[:contact_form][:website_url].present?

    timestamp = session[:contact_form_timestamp]
    return true if timestamp.nil? || (Time.current.to_i - timestamp < 3)

    false
  end
end
