module Events
  module Trips
    class Update < BaseEvent
      include Validations::Update
      include Concerns::Payments

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:departure).filled
          required(:departure_address).filled(:str?)
          required(:destination).filled
          required(:destination_address).filled(:str?)
          required(:distance).filled(:int?)
          required(:duration).filled(:int?)
          required(:path).filled(:str?)

          optional(:waypoints) { none? | array? }
          optional(:stops) { none? | array? }
          optional(:time) { str? }
          optional(:no_call)
          optional(:card_id)
          optional(:osrm)
          optional(:entrance)
          optional(:comment) { str? }
          optional(:bonus)
          optional(:by_driver).filled(:bool?)
        end
      end

      def run
        validate!
        cancel_previous_hold
        update_trip
        update_payment unless bonus?
        broadcast_unavailable_to_trip
        hold_money
        trip
      end

      private

      def cancel_previous_hold
        Fondy::Reverse.new(trip.cost, trip.trip_payment.order_reference).call
      end

      def hold_money
        Fondy::Recurring.new(user, trip.cost, card_token, order_reference).call
      end

      def update_trip
        trip.update(trip_params)
      end

      def update_payment
        if bonus_trip
          bonus_trip.update(status: :fresh, trip_id: nil)
          update_trip_payment
        else
          trip.trip_payment.update(payment_params)
        end
      end

      def bonus_trip
        @bonus_trip ||= trip.bonus_trip
      end

      def update_trip_payment
        trip.trip_payment.update(
          status: Constants::Payments::PENDING,
          amount: trip.cost,
          card_id: card_id,
          order_reference: order_reference
        )
      end

      def broadcast_unavailable_to_trip
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_UPDATED,
          data: Presenters::Trips::Detailed.new(trip).to_json,
          by_driver: updated_by_driver?
        )
      end

      def card_id
        card = user_cards.detect { |c| c.id == data[:card_id].to_i } if data[:card_id]
        card&.id || user_cards.first.id
      end

      def user_cards
        @user_cards ||= Card.user_cards(trip.user_id)
      end

      def trip
        @trip ||= Trip.find(data[:id])
      end

      def bonus?
        data[:bonus].present?
      end

      def updated_by_driver?
        data[:by_driver].present?
      end

      def trip_params
        data.slice(:path, :cost, :departure, :destination, :departure_address,
                   :destination_address, :duration, :distance, :stops, :waypoints)
      end

      def payment_params
        params = {amount: trip.cost, order_reference: order_reference}
        params[:card_id] = data[:card_id] if data[:card_id]
        params
      end

      def user
        @user ||= User.find(trip.user_id)
      end

      def card_token
        @card_token ||= Card.find(card_id).token
      end
    end
  end
end
