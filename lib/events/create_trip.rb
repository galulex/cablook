module Events
  class CreateTrip < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:path).filled(:str?)
        required(:cost).filled(:float?)
        required(:user_id).filled(:int?)
      end
    end

    def run
      validate!
      create_trip
    end

    private

    def validate!
      validator = Trips::Validator.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_trip
      Trips::Repository.new.create(data.to_h)
    end
  end
end
