module Events
  module DriversApp
    class Authorize < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:username).filled(:str?)
          required(:password).filled(:str?)
        end
      end

      def run
        check_username!
        check_password!
        validate_driver_car!
        update_driver_token
        set_free_status
        driver
      end

      private

      def validate_driver_car!
        invalid!([I18n.t('driver.authorizations.errors.car_not_assigned')]) unless driver.car
      end

      def update_driver_token
        driver.regenerate_auth_token
      end

      def driver
        @driver ||= Driver.find_by(username: data[:username])
      end

      def set_free_status
        driver.car.update(status: heve_active_trips? ? Constants::Car::DURING_TRIP : Constants::Car::FREE)
      end

      def heve_active_trips?
        driver.car.trips.where(status: Constants::Trip::CURRENT_TRIP_STATUSES, preorder_time: nil).size.positive?
      end

      def encrypted_password
        @encrypted_password ||= BCrypt::Password.new(driver.encrypted_password)
      end

      def check_username!
        invalid!([I18n.t('authorizations.errors.invalid_username')]) unless driver
      end

      def check_password!
        invalid!([I18n.t('authorizations.errors.invalid_password')]) unless encrypted_password == data[:password]
      end
    end
  end
end
