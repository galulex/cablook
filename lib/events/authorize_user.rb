module Events
  class AuthorizeUser < BaseEvent
    def schema
      Dry::Validation.Schema do
        configure { config.messages = :i18n }

        required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
      end
    end

    def run
      Jobs::Sms.perform_later(data[:phone_number], code)
      update_code
      user || create_user
    end

    private

    def update_code
      Repositories::User.new(ROM.env).update(user.id, verification_token: code) if user
    end

    def user
      @user ||= Repositories::User.new(ROM.env).by_phone_number(data[:phone_number])
    end

    def create_user
      @user ||= Repositories::User.new(ROM.env).create(data.merge(
                                                         auth_token: SecureRandom.base58(24),
                                                         verification_token: code,
                                                         referral_code: SecureRandom.base58(6)
      ))
    end

    def code
      @code ||= rand(1000..9999)
    end
  end
end
