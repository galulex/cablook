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
        send_and_create_tip_for_driver if data[:tip]&.positive?
        create_feedback
      end

      private

      def create_feedback
        Feedback.create(data.to_h.except(:tip))
      end

      def send_and_create_tip_for_driver
        Jobs::PaymentSettle.perform_later(data[:trip_id], Constants::Payments::TYPES[:tip].camelcase, data[:tip])
      end
    end
  end
end
