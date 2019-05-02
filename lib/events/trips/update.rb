module Events
  module Trips
    class Update < BaseEvent
      include Validations::Update

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
          optional(:osrm)
          optional(:entrance)
          optional(:comment) { str? }
          optional(:bonus)
        end
      end

      def run
        validate!

        update_trip
        update_payment unless bonus?
        broadcast_unavailable_to_trip
        trip
      end

      private

      def update_trip
        trip.update(trip_params)
      end

      def update_payment
        if bonus_trip
          bonus_trip.update(status: Constants::BonusTrip::NEW, trip_id: nil)
          update_trip_payment
        else
          trip.trip_payment.update(amount: trip.cost)
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
          data: Presenters::Trips::Single.new(trip).to_json
        )
      end

      def card_id
        card = user_cards.detect { |c| c.id == data[:card_id].to_i } if data[:card_id]
        card&.id || user_cards.first.id
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
      end

      def trip
        @trip ||= Trip.find(data[:id])
      end

      def bonus?
        data[:bonus].present?
      end

      def order_reference
        @order_reference ||= if Rails.env.production?
                               "cablook_trip_#{trip.id}"
                             else
                               "cablook_#{Rails.env}_trip_#{trip.id}"
                             end
      end

      def trip_params
        data.slice(:path, :cost, :departure, :destination, :departure_address,
                   :destination_address, :duration, :distance, :stops, :waypoints)
      end
    end
  end
end

