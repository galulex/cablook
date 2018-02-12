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

          optional(:card_id).filled(:int?)
          optional(:bouns).filled(:bool?)
        end
      end

      def run
        convert_location_to_pg_array
        validate_unpaid_trips!
        create_trip
        if data[:bonus]
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
        invalid!([I18n.t('trips.pay_off_debt')]) if pending_payments.any?
      end

      def hold_payment
        Jobs::PaymentHold.perform_later(@trip.id, card_id)
      end

      def pay_by_bonus
        bonus_trips = Repositories::BonusTrip.new(ROM.env).available_by_user(data[:user_id])
        if bonus_trips.any?
          Repositories::Payment.new(ROM.env).create(
            status: Constants::Payments::BONUS,
            amount: 0,
            trip_id: @trip.id,
            user_id: data[:user_id]
          )
          Repositories::BonusTrip.new(ROM.env).update(bonus_trips.first.id, status: Constants::BonusTrip::USED, trip_id: @trip.id)
        else
          invalid!(I18n.t('bonus_trips.no_available_bonus'))
        end
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

      def convert_location_to_pg_array
        data[:departure] = Sequel.pg_array(data[:departure])
        data[:destination] = Sequel.pg_array(data[:destination])
        data[:distance] = matrix.distance
        data[:duration] = matrix.duration
        data[:cost] = cost
      end

      def matrix
        @matrix ||= SearchEngine::Matrix.new(data[:departure], data[:destination])
      end

      def cost
        cost = (matrix.distance / 1000.0).ceil(1) * Constants::Trip::CENTS_PER_KM + Constants::Trip::LANDING
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
