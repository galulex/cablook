module Events
  module DriversApp
    class AssignCar < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:driver_id).filled(:int?)
          required(:car_id).filled(:int?)
        end
      end

      def run
        validate!
        assign_car
        driver
      end

      private

      def assign_car
        Car.find(data[:car_id]).update(status: Constants::Car::FREE)
        driver.update(car_id: data[:car_id])
      end

      def driver
        @driver ||= Driver.find(data[:driver_id])
      end

      def validate!
        invalid!([I18n.t('assignings.errors.messages.has_already_been_taken')]) if Driver.find_by(car_id: data[:car_id])
      end
    end
  end
end
