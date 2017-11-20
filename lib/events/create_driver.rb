module Events
  class CreateDriver < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:name).filled(:str?)
        required(:username).filled(:str?)
        required(:encrypted_password).filled(:str?)
      end
    end

    def run
      validate!
      create_driver
    end

    private

    def validate!
      validator = Validators::Driver.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_driver
      Repositories::Driver.new(ROM.env).create(data.merge(auth_token: SecureRandom.base58(24)))
    end
  end
end
