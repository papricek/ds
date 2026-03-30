class BillingMailer < ApplicationMailer
  def receipt_notification(billing)
    @billing = billing
    @user = billing.user
    @account = billing.account

    mail(
      to: @user.email,
      subject: t("mailer.receipt_notification.subject", symbol: @billing.variable_symbol)
    )
  end
end
