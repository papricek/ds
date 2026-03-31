class ContactFormMailer < ApplicationMailer
  ADMINS = ["patrikjira@gmail.com"].freeze

  def notify_admin(contact_form)
    @contact_form = contact_form
    mail(to: ADMINS, subject: t("contact_form_mailer.notify_admin.subject"))
  end
end
