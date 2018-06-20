module Events
  module Cars
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:number).filled(:str?)
          optional(:color).filled(:str?)
        end
      end

      def run
        validate!
        create_car
      end

      private

      def validate!
        @car = Car.new(data)
        invalid!(@car.errors.values.flatten) if @car.invalid?
      end

      def create_car
        @car.save
      end
    end
  end
end
