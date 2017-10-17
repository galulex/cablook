module Events
  module Verifications
    class SendEmailVerification < BaseEvent
      def schema
        Dry::Validation.Schema do
          required(:email).value(format?: Constants::Regex::EMAIL)
        end
      end

      def run
        check_user!
        check_is_confirmed!
        send_confirmation_link
        update_user_confirmation_token
      end

      private

      def update_user_confirmation_token
        Repositories::User.new.update(user.id, confirmation_token: token)
      end

      def send_confirmation_link
        EmailConfirmationMailer.email_confirmation(
          user: user,
          message: I18n.t('verifications.email.send_confirmation_token', token: token),
          subject: I18n.t('verifications.email.confirmation_subject')
        ).deliver
      end

      def check_user!
        invalid!([I18n.t('verifications.errors.email.does_not_exist')]) unless user
      end

      def check_is_confirmed!
        invalid!([I18n.t('verifications.errors.email.already_confirmed')]) if user.confirmation_token.blank?
      end

      def user
        @user ||= Repositories::User.new.by_email(data[:email])
      end

      def token
        @token ||= rand(1000..9999).to_s
      end
    end
  end
end
