class EmailConfirmationMailer < ApplicationMailer
  def email_confirmation(user, message, subject)
    @email = user.email
    @token = user.confirmation_token
    @message = message
    mail to: @email, subject: subject
  end
end
