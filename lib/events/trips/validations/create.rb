module Events
  module Trips
    module Validations
      module Create
        include Concerns::Validation

        private

        def validate!
          validate_distance!
          validate_unpaid_trips!
          validate_trip!
          validate_card!
          validate_bonus! if bonus?
        end

        def validate_unpaid_trips!
          return unless settings.validate_unpaid_trips
          pending_payments = Trip.unpaid.where(user_id: data[:user_id])
          invalid!([I18n.t('trips.pay_off_debt')], status: 418) if pending_payments.any?
        end

        def validate_trip!
          return if Trip.pending.where(user_id: data[:user_id]).blank?
          invalid!([I18n.t('trips.pending_trip_exists')])
        end

        def validate_card!
          return if cash_trip
          invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
        end

        def validate_bonus!
          return if (bonus_trips.any? || data[:cost] <= user.cashback) && data[:distance] < Constants::Trip::MAX_BONUS_DISTANCE
          invalid!([I18n.t('bonus_trips.no_available_bonus')], status: 406)
        end

        def validate_hold_amount!
          unless cash_trip || hold_success?
            @trip.destroy
            invalid!([I18n.t('trips.cant_hold_amount')], status: 402)
          end
        end
      end
    end
  end
end
