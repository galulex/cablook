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
      invalid!(I18n.t('verifications.errors.invalid_or_expired')) unless user
      return user if custom_iphone?
      user.update(verification_token: nil)
      user
    end

    private

    def user
      @user ||= User.for_verification(data[:phone_number], data[:token]).first
    end

    def custom_iphone?
      data[:phone_number] == '+380000000000'
    end
  end
end
