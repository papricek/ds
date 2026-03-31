class ContactFormMailerPreview < ActionMailer::Preview
  def notify_admin
    contact_form = ContactForm.last || ContactForm.new(
      name: "Jan Novák",
      email: "jan@example.com",
      phone: "+420 777 123 456",
      message: "Mám zájem o platformu LiteLink pro naši obec."
    )
    ContactFormMailer.notify_admin(contact_form)
  end
end
