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
          optional(:stops) { none? | array? }

          optional(:comment) { str? }
          optional(:card_id)
          optional(:bouns).filled(:bool?)
        end
      end

      def run
        assign_attrs
        validate_distance!
        validate_unpaid_trips!
        validate_card!
        validate_bonus! if data[:bonus]
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
        pending_payments = Payments::Trip.where(status: Constants::Payments::PENDING, user_id: data[:user_id])
        invalid!([I18n.t('trips.pay_off_debt')], status: 418) if pending_payments.any?
      end

      def validate_card!
        invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
      end

      def validate_distance!
        return if trip_calculation.distance < Constants::Trip::MAX_DISTANCE
        invalid!([I18n.t('trips.to_far')])
      end

      def validate_bonus!
        return if bonus_trips.any? && trip_calculation.distance < Constants::Trip::MAX_BONUS_DISTANCE
        invalid!([I18n.t('bonus_trips.no_available_bonus')])
      end

      def hold_payment
        Jobs::PaymentHold.perform_later(@trip.id, card_id)
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
        @trip = Trip.create(data.to_h.except(:bonus, :card_id))
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::PaymentRefundDeclined.set(wait: 10.minutes).perform_later(trip_id)
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
        data[:cost] = trip_calculation.cost
      end

      def bonus_trips
        @bonus_trips ||= BonusTrip.where(user_id: data[:user_id], status: Constants::BonusTrip::NEW)
      end

      def trip_calculation
        @trip_calculation ||= Operations::TripCalculation.new(
          departure: data[:departure],
          destination: data[:destination],
          waypoints: data[:waypoints]
        )
      end

      def card_id
        card = user_cards.detect { |c| c.id == data[:card_id] } if data[:card_id]
        card&.id || user_cards.first.id
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
      end
    end
  end
end
