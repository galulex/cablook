module Events
  class Authorization < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
        required(:password).filled(:str?)
      end
    end

    def run
      check_phone_number!
      check_password!
      user
    end

    private

    def user
      @user ||= Repositories::User.new(ROM.env).by_phone_number(data[:phone_number])
    end

    def encrypted_password
      @encrypted_password ||= BCrypt::Password.new(user.encrypted_password)
    end

    def check_phone_number!
      invalid!([I18n.t('authorizations.errors.invalid_phone_number')]) unless user
    end

    def check_password!
      invalid!([I18n.t('authorizations.errors.invalid_password')]) unless encrypted_password == data[:password]
    end
  end
end
