module Events
  class CreateCar < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:number).filled(:str?)
      end
    end

    def run
      validate!
      create_car
    end

    private

    def validate!
      validator = Validators::Car.new(data)
      invalid!(validator.errors.messages) if validator.invalid?
    end

    def create_car
      Repositories::Car.new(ROM.env).create(data.to_h)
    end
  end
end
