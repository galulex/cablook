module Events
  module DriversApp
    class SignOut < BaseEvent
      def schema
        Dry::Validation.Schema do
          required(:driver_id).filled(:int?)
        end
      end

      def run
        update_car_status_to_offline
        regenerate_auth_token_for_driver
        broadcast_to_driver_map
      end

      private

      def update_car_status_to_offline
        car.update(status: Constants::Car::OFFLINE)
      end

      def regenerate_auth_token_for_driver
        driver.update(auth_token: SecureRandom.base58(24), car_id: nil)
      end

      def broadcast_to_driver_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::DRIVER_SIGN_OUT,
          driver_id: driver.id,
          car_id: car.id
        )
      end

      def driver
        @driver ||= Driver.find(data[:driver_id])
      end

      def car
        @car ||= driver.car
      end
    end
  end
end
