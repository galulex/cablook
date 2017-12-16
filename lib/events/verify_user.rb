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
      check_user
      verify!
    end

    private

    def check_user
      invalid!(errors: [I18n.t('verifications.errors.invalid_or_expired')]) unless user
    end

    def verify!
      users_repo.update(user.id, verification_token: nil)
    end

    def user
      @user ||= users_repo.for_verification(data[:phone_number], data[:token])
    end

    def users_repo
      @users_repo ||= Repositories::User.new(ROM.env)
    end
  end
end
