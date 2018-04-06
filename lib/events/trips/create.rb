module Events
  module Trips
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:path).filled(:str?)
          required(:user_id).filled(:int?)

          required(:departure) { array? & size?(2) }
          required(:destination) { array? & size?(2) }
          required(:departure_address).filled(:str?)
          required(:destination_address).filled(:str?)
          optional(:waypoints) { none? | array? }

          optional(:comment) { str? }
          optional(:card_id).filled(:int?)
          optional(:bouns).filled(:bool?)
        end
      end

      def run
        assign_attrs
        validate_distance!
        validate_unpaid_trips!
        create_trip
        if data[:bonus]
          validate_bonus!
          pay_by_bonus
        else
          hold_payment
        end
        create_trip_job(@trip.id)
        @trip
      end

      private

      def validate_unpaid_trips!
        pending_payments = Repositories::Payment.new(ROM.env).pending_by_user(data[:user_id])
        invalid!([I18n.t('trips.pay_off_debt')], status: 418) if pending_payments.any?
      end

      def validate_distance!
        return if trip_calculation.distance < Constants::Trip::MAX_DISTANCE
        invalid!([I18n.t('trips.to_far')])
      end

      def validate_bonus!
        return if bonus_trips.any? && trip_calculation.distance < Constants::Trip::MAX_BONUS_DISTANCE
        invalid!(I18n.t('bonus_trips.no_available_bonus'))
      end

      def hold_payment
        Jobs::PaymentHold.perform_later(@trip.id, card_id)
      end

      def pay_by_bonus
        Repositories::Payment.new(ROM.env).create(
          status: Constants::Payments::BONUS,
          amount: 0,
          trip_id: @trip.id,
          user_id: data[:user_id]
        )
        Repositories::BonusTrip.new(ROM.env).update(bonus_trips.first.id, status: Constants::BonusTrip::USED, trip_id: @trip.id)
      end

      def create_trip
        @trip = Repositories::Trip.new(ROM.env).create(data.to_h)
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::PaymentRefundDeclined.set(wait: 15.minutes).perform_later(trip_id)
        job = Jobs::SearchCarForTrip.perform_later(trip_id)
        Repositories::TripJob.new(ROM.env).create(
          activejob_id: job.job_id,
          sidekiq_id: job.provider_job_id,
          trip_id: trip_id
        )
      end

      def assign_attrs
        data[:departure] = Sequel.pg_array(data[:departure])
        data[:destination] = Sequel.pg_array(data[:destination])
        data[:distance] = trip_calculation.distance
        data[:duration] = trip_calculation.duration
        data[:cost] = trip_calculation.cost
        data[:waypoints] = Sequel.pg_array(data[:waypoints]) if data[:waypoints]&.any?
      end

      def bonus_trips
        @bonus_trips ||= Repositories::BonusTrip.new(ROM.env).available_by_user(data[:user_id])
      end

      def trip_calculation
        @trip_calculation ||= Operations::TripCalculation.new(
          departure: data[:departure],
          destination: data[:destination],
          waypoints: data[:waypoints]
        )
      end

      def card_id
        user_cards = Repositories::Card.new(ROM.env).by_user(data[:user_id])
        invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
        data[:card_id] || user_cards.first.id
      end
    end
  end
end
