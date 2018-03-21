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
          optional(:waypoints) { array? }

          optional(:comment).filled(:str?)
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
        return if matrix.distance < Constants::Trip::MAX_DISTANCE
        invalid!([I18n.t('trips.to_far')])
      end

      def validate_bonus!
        return if bonus_trips.any? && matrix.distance < Constants::Trip::MAX_BONUS_DISTANCE
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
        data[:distance] = matrix.distance
        data[:duration] = matrix.duration
        data[:cost] = cost
      end

      def bonus_trips
        @bonus_trips ||= Repositories::BonusTrip.new(ROM.env).available_by_user(data[:user_id])
      end

      def matrix
        @matrix ||= SearchEngine::Directions.new(data[:departure], data[:destination], data[:waypoints]&.map { |w| w.split(',') })
      end

      def cost
        cost = (matrix.distance / 1000.0).ceil(1) * Constants::Trip::CENTS_PER_KM + Constants::Trip::LANDING
        cost = Constants::Trip::MIN_PRICE if cost < Constants::Trip::MIN_PRICE
        ((cost + cost * Constants::Trip::FEE) / 100).ceil
      end

      def card_id
        user_cards = Repositories::Card.new(ROM.env).by_user(data[:user_id])
        invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
        data[:card_id] || user_cards.first.id
      end
    end
  end
end
