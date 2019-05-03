module Events
  module Trips
    class Create < BaseEvent
      include Concerns::Direction
      include Validations::Create

      FIELDS = %i[duration distance].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:path).filled(:str?)
          required(:user_id).filled(:int?)

          required(:departure).filled
          required(:destination).filled
          required(:departure_address).filled(:str?)
          required(:destination_address).filled(:str?)
          optional(:waypoints) { none? | array? }
          optional(:stops) { none? | array? }

          optional(:time) { str? }
          optional(:no_call)
          optional(:osrm)
          optional(:entrance)
          optional(:comment) { str? }
          optional(:card_id)
          optional(:bonus)
        end
      end

      def run
        assign_attrs
        validate!

        create_trip
        bonus? ? pay_by_bonus : create_payment
        create_trip_job(@trip.id)
        @trip
      end

      private

      def assign_attrs
        FIELDS.each { |field| data[field] = direction.send(field) }
        data[:cost] = Operations::V2TripCalculation.new(direction).cost
      end

      def create_payment
        Payments::Trip.create(
          status: Constants::Payments::PENDING,
          amount: @trip.cost,
          user_id: @trip.user_id,
          card_id: card_id,
          trip_id: @trip.id,
          order_reference: order_reference
        )
      end

      def pay_by_bonus
        Payments::Trip.create(
          status: Constants::Payments::BONUS,
          amount: 0,
          trip_id: @trip.id,
          user_id: data[:user_id]
        )
        bonus_trips.first.update(status: Constants::BonusTrip::USED, trip_id: @trip.id)
      end

      def create_trip
        @trip = Trip.create(data.to_h.except(:bonus, :card_id, :id, :status, :created_at, :idle, :car_id, :driver_id, :finished_at, :arrived_at, :started_at, :feedbacks))
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::SearchCarForTrip.perform_later(trip_id)
      end

      def bonus_trips
        @bonus_trips ||= BonusTrip.where(user_id: data[:user_id], status: Constants::BonusTrip::NEW)
      end

      def card_id
        card = user_cards.detect { |c| c.id == data[:card_id].to_i } if data[:card_id]
        card&.id || user_cards.first.id
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
      end

      def bonus?
        data[:bonus].present?
      end

      def order_reference
        @order_reference ||= if Rails.env.production?
                               "cablook_trip_#{@trip.id}"
                             else
                               "cablook_#{Rails.env}_trip_#{@trip.id}"
                             end
      end
    end
  end
end
