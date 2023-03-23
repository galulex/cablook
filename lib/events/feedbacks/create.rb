module Events
  module Feedbacks
    class Create < BaseEvent
      TIP_PAYMENT = 'Payments::Tip'.freeze
      TRIP_PAYMENT = 'Payments::Trip'.freeze

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
        if data[:tip]&.positive?
          create_tip_payment
          validate_hold_money!
          send_tip_for_driver
        end
        create_feedback
      end

      private

      def create_feedback
        Feedback.create(data.to_h.except(:tip))
      end

      def send_tip_for_driver
        Jobs::PaymentSettle.perform_later(data[:trip_id], Constants::Payments::TYPES[:tip], data[:tip])
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def create_tip_payment
        trip.payments.create(
            trip_id: data[:trip_id],
            user_id: data[:user_id],
            card_id: card.id,
            type: TIP_PAYMENT,
            amount: data[:tip],
            order_reference: tip_order_reference)
      end

      def tip_order_reference
        result = trip.payments.where(type: TRIP_PAYMENT).first.order_reference
        result.sub!(Constants::Payments::TYPES[:trip].downcase, Constants::Payments::TYPES[:tip].downcase)
        @tip_order_reference ||= result
      end

      def card
        trip.trip_payment&.card || trip.user.cards.last
      end

      def user
        User.find(data[:user_id])
      end

      def hold_money_for_tip
        Fondy::Recurring.new(user, data[:tip], card.token, tip_order_reference).call
      end

      def success_hold?
        hold_money_for_tip[:response_status] == Constants::Payments::FONDY_SUCCESS
      end

      def validate_hold_money!
        return if hold_money_for_tip[:response_status] == Constants::Payments::FONDY_SUCCESS
        trip.payments.find_by!(order_reference: tip_order_reference).destroy
        invalid!([I18n.t('cards.hold_failed')]) 
      end
    end
  end
end
