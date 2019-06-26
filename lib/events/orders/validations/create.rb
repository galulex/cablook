module Events
  module Orders
    module Validations
      module Create
        private

        def validate!
          validate_unpaid_trips!
          validate_trip!
          validate_card!
          validate_items!
        end

        def validate_unpaid_trips!
          pending_payments = Trip.unpaid.where(user_id: data[:user_id])
          invalid!([I18n.t('trips.pay_off_debt')], status: 418) if pending_payments.any?
        end

        def validate_trip!
          return if Trip.pending.where(user_id: data[:user_id]).blank?
          invalid!([I18n.t('trips.pending_trip_exists')])
        end

        def validate_card!
          invalid!([I18n.t('cards.add_card')]) if user_cards.empty?
        end

        def validate_items!
          invalid!([I18n.t('orders.no_items')]) if calculate_amount.zero?
        end
      end
    end
  end
end
