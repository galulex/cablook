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
        Repositories::Car.new(ROM.env).update(
          driver.car_id,
          status: Constants::Car::OFFLINE,
        )
      end

      def regenerate_auth_token_for_driver
        driver_repository.update(
          driver.id,
          auth_token: SecureRandom.base58(24),
          car_id: nil
        )
      end

      def broadcast_to_driver_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::DRIVER_SIGN_OUT,
          driver_id: driver.id,
          car_id: driver.car_id
        )
      end

      def driver
        @driver ||= driver_repository.by_id(data[:driver_id])
      end

      def driver_repository
        @driver_repository ||= Repositories::Driver.new(ROM.env)
      end
    end
  end
end
