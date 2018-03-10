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
        reset_status!
        driver
      end

      private

      def reset_status!
        return unless driver.car_id
        Repositories::Car.new(ROM.env).update(driver.car_id, status: Constants::Car::OFFLINE)
        @driver = Repositories::Driver.new(ROM.env).update(driver.id, car_id: nil)
      end

      def driver
        @driver ||= Repositories::Driver.new(ROM.env).by_username(data[:username])
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
