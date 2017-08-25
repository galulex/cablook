module Events
  class CreateUser < BaseEvent
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

    def schema
      Dry::Validation.Schema do
        required(:email).filled(format?: EMAIL_REGEX)
        required(:encrypted_password).filled(:str?)
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
