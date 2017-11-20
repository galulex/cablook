module Events
  class CreateSubscription < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:email).maybe(format?: Constants::Regex::EMAIL)
      end
    end

    def run
      validate!
      create_subscription
    end

    private

    def validate!
      validator = Validators::Subscription.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_subscription
      Repositories::Subscription.new(ROM.env).create(data.to_h.merge(created_at: Time.now))
    end
  end
end
