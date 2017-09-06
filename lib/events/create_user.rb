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
      token = send_number_verification
      create_user(token)
    end

    private

    def validate!
      validator = Validators::User.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_user(verification_token)
      Repositories::User.new.create(data.merge(auth_token: SecureRandom.base58(24),
                                               verification_token: verification_token))
    end

    def send_number_verification
      Events::Verifications::SendNumberVerification.(number: data[:phone_number])
    end
  end
end
