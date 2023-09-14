module Events
  module Feedbacks
    class Create < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

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
        Payment.find_or_create_by(payment_attributes)
        Jobs::PaymentSettle.perform_later(data[:trip_id], Constants::Payments::TYPES[:tip], data[:tip])
      end

      def card
        trip.trip_payment&.card || trip.user.cards.last
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def payment_attributes
        {
          trip_id: data[:trip_id],
          user_id: data[:user_id],
          card_id: card.id, 
          type: Constants::Payments::TIP
        }
      end
    end
  end
end
