class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: t("mailer.welcome.subject"))
  end

  def reset_password(user)
    @user = user
    @token = @user.user_tokens.password_reset.valid.last
    mail(to: @user.email, subject: t("mailer.reset_password.subject"))
  end
end
