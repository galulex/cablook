module Events
  module Drivers
    class Create < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:name).filled(:str?)
          required(:username).filled(:str?)
          required(:encrypted_password).filled(:str?)
        end
      end

      def run
        validate!
        create_driver
        @driver
      end

      private

      def validate!
        @driver = Driver.new(data.merge(auth_token: SecureRandom.base58(24)))
        invalid!(@driver.errors.full_messages.flatten) if @driver.invalid?
      end

      def create_driver
        @driver.save
      end
    end
  end
end
