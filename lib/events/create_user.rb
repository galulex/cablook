module Events
  class CreateUser < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:phone_number).value(size?: 12)
        required(:encrypted_password).filled(:str?)

        optional(:email).maybe(format?: Constants::Regex::EMAIL)
      end
    end

    def run
      validate!
      create_user
    end

    private

    def validate!
      validator = Validators::User.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_user
      auth_token = SecureRandom.base58(24)
      Repositories::User.new.create(data.merge(auth_token: auth_token))
    end
  end
end
