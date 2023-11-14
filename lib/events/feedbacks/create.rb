module Events
  module Feedbacks
    class Create < BaseEvent
      def schema
        Dry::Schema.Params do
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
        return create_tip_mobile_payment if mobile_pay?

        Payment.find_or_create_by(payment_attributes)
        Jobs::PaymentSettle.perform_later(data[:trip_id], Constants::Payments::TYPES[:tip], data[:tip])
      end

      def create_tip_mobile_payment
        response = Fondy::Recurring.new(trip.user, data[:tip], trip.trip_payment['response']['rectoken'], trip.trip_payment.order_reference + '_tip', false).call
        trip.driver.update!(balance: trip.driver.balance + data[:tip]) if response[:status]

        Payment.find_or_create_by(payment_attributes.merge({ payment_method: Constants::Payments::METHOD_MOBILE,
                                                             amount: data[:tip],
                                                             response: response,
                                                             status: response[:status] ? Constants::Payments::SUCCESS : Constants::Payments::PENDING }))
      end

      def mobile_pay?
        trip.trip_payment.payment_method == Constants::Payments::METHOD_MOBILE
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
          card_id: mobile_pay? ? nil : card.id,
          type: Constants::Payments::TIP
        }
      end
    end
  end
end
