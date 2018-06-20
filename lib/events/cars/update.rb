module Events
  module Cars
    class Update < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:id).filled(:int?)
          optional(:number).filled(:str?)
          optional(:color).filled(:str?)
        end
      end

      def run
        update_car
      end

      private

      def update_car
        Car.find(data[:id]).update(data.to_h.except(:id))
      end
    end
  end
end
