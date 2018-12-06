module Events
  module Trips
    class Create < BaseEvent
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
        validate_distance!
        validate_unpaid_trips!
        validate_trip!
        validate_card!
        validate_bonus! if data[:bonus]
        create_trip
        if data[:bonus]
          pay_by_bonus
        else
          create_payment
        end
        create_trip_job(@trip.id)
        @trip
      end

      private

      def validate_unpaid_trips!
        pending_payments = Trip.unpaid.where(user_id: data[:user_id])
        invalid!([I18n.t('trips.pay_off_debt')], status: 418) if pending_payments.any?
      end

      def validate_card!
        invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
      end

      def validate_distance!
        return if trip_calculation.distance < Constants::Trip::MAX_DISTANCE
        invalid!([I18n.t('trips.to_far')])
      end

      def validate_trip!
        return if Trip.pending.where(user_id: data[:user_id]).blank?
        invalid!([I18n.t('trips.pending_trip_exists')])
      end

      def validate_bonus!
        return if bonus_trips.any? && trip_calculation.distance < Constants::Trip::MAX_BONUS_DISTANCE
        invalid!([I18n.t('bonus_trips.no_available_bonus')])
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
        BonusTrip.find(bonus_trips.first.id).update(status: Constants::BonusTrip::USED, trip_id: @trip.id)
      end

      def create_trip
        @trip = Trip.create(data.to_h.except(:bonus, :card_id, :id, :status, :created_at, :idle, :car_id, :driver_id, :finished_at, :arrived_at, :started_at))
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        job = Jobs::SearchCarForTrip.perform_later(trip_id)
        TripJob.create(
          activejob_id: job.job_id,
          sidekiq_id: job.provider_job_id,
          trip_id: trip_id
        )
      end

      def assign_attrs
        data[:distance] = trip_calculation.distance
        data[:duration] = trip_calculation.duration
        data[:cost] = Operations::V2TripCalculation.new(trip_calculation).cost
      end

      def bonus_trips
        @bonus_trips ||= BonusTrip.where(user_id: data[:user_id], status: Constants::BonusTrip::NEW)
      end

      def trip_calculation
        @trip_calculation ||= directions_provider.new(
          data[:departure],
          data[:destination],
          data[:waypoints] || []
        )
      end

      def directions_provider
        data[:osrm].present? ? OsrmDirections : Directions
      end

      def card_id
        card = user_cards.detect { |c| c.id == data[:card_id].to_i } if data[:card_id]
        card&.id || user_cards.first.id
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
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
