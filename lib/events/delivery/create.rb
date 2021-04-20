module Events
  module Delivery
    class Create < BaseEvent
      TRIP_PARAMS = %i[departure departure_address destination destination_address entrance].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:vendor_id).filled(:int?)
          required(:trip_time).filled(:str?)
          required(:card_id).filled(:int?)
          required(:user_id).filled(:int?)
          required(:items)
        end
      end

      def run
        create_order!
        return order unless order[:valid]

        create_trip!
      end

      private

      def order
        @order ||= Events::Orders::Create.(order_params)
      end
      alias create_order! order

      def order_params
        data.slice(:vendor_id, :trip_time, :card_id, :items, :user_id)
      end

      def create_trip!
        trip = Events::Trips::Create.(trip_params)
        Presenters::Trips::Single.new(trip).to_json
      end

      def trip_params
        data[:trip].slice(*TRIP_PARAMS).merge(additional_params)
      end

      def additional_params
        { user_id: data[:user_id], osrm: true, order_id: @order[:order_id], time: data[:trip_time] }.merge(comment)
      end

      def comment
        { comment: "Доставка їжі з закладу: #{vendor.name}. "\
                   "Номер телефону закладу: #{vendor.phone_number}."\
                   " #{data.dig(:trip, :comment)}" }
      end

      def vendor
        @vendor ||= Vendor.find(data[:vendor_id])
      end
    end
  end
end
