module Events
  module DriversApp
    class SignOut < BaseEvent
      def schema
        Dry::Schema.Params do
          required(:driver_id).filled(:int?)
        end
      end

      def run
        car&.offline!
        update_driver_device
        broadcast_to_driver_map
      end

      private

      def broadcast_to_driver_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::DRIVER_SIGN_OUT,
          driver_id: driver.id,
          car_id: car&.id
        )
      end

      def update_driver_device
        driver.update!(device: nil, device_platform: nil)
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
