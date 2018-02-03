module Events
  class VerifyUser < BaseEvent
    def schema
      Dry::Validation.Schema do
        configure { config.messages = :i18n }

        required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
        required(:token).filled(:str?)
      end
    end

    def run
      invalid!(errors: [I18n.t('verifications.errors.invalid_or_expired')]) unless user
      user.update(verification_token: nil)
      user
    end

    private

    def user
      @user ||= User.for_verification(data[:phone_number], data[:token]).first
    end
  end
end
