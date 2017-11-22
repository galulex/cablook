module Events
  class CreateUser < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
        required(:encrypted_password).filled(:str?)

        optional(:email).maybe(format?: Constants::Regex::EMAIL)
      end
    end

    def run
      validate!
      user = create_user
      send_number_verification # TODO: Do this staff in background
      user
    end

    private

    def validate!
      validator = Validators::User.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_user
      Repositories::User.new(ROM.env).create(data.merge(auth_token: SecureRandom.base58(24)))
    end

    def send_number_verification
      Events::Verifications::SendNumberVerification.(number: data[:phone_number])
    end
  end
end
