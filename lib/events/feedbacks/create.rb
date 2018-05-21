module Events
  module Feedbacks
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:rate) { int? & gt?(0) & lteq?(5) }
          required(:trip_id).filled(:int?)
          required(:user_id).filled(:int?)
          optional(:description).filled(:str?)
          optional(:tip).filled(:int?)
        end
      end

      def run
        validate!
        send_and_create_tip_for_driver if data[:tip]
        create_feedback
      end

      private

      def validate!
        validator = Validators::Feedback.new(data)
        invalid!(validator.errors.values.flatten) if validator.invalid?
      end

      def create_feedback
        Repositories::Feedback.new(ROM.env).create(data.to_h)
      end

      def send_and_create_tip_for_driver
      end
    end
  end
end
