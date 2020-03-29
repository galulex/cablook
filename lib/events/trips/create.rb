module Events
  module Trips
    class Create < BaseEvent
      include Concerns::Direction
      include Validations::Create

      FIELDS = %i[duration distance path].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

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
          optional(:delivery)
          optional(:order_id)
        end
      end

      def run
        assign_attrs
        validate!

        update_trip_time if delivery?
        create_trip
        bonus? ? pay_by_bonus : create_payment
        order_operations if delivery?
        create_trip_job(@trip.id) unless delivery?
        @trip
      end

      private

      def assign_attrs
        FIELDS.each { |field| data[field] = direction.send(field) }
        data[:cost] = Operations::V2TripCalculation.new(direction).cost
      end

      def order_operations
        @trip.waiting_for_vendor_approve!
        assign_trip_to_order
        assign_trip_to_order_payment
        update_trip_comment
        approve_by_vendor
      end

      def order
        @order ||= Order.find_by(id: data[:order_id])
      end

      def assign_trip_to_order
        order.update(trip_id: @trip.id)
      end

      def assign_trip_to_order_payment
        order.payment.update(trip_id: @trip.id)
      end

      def update_trip_comment
        @trip.update(comment: @trip.comment.prepend("Номер замовлення: ##{@order.id}. Товари: #{@order.items} "))
      end

      def create_payment
        Payments::Trip.create(
          status: Constants::Payments::PENDING,
          amount: @trip.cost,
          user_id: @trip.user_id,
          card_id: card_id,
          trip_id: @trip.id
        )
      end

      def pay_by_bonus
        Payments::Trip.create(
          status: Constants::Payments::BONUS,
          amount: 0,
          trip_id: @trip.id,
          user_id: data[:user_id]
        )
        bonus_trips.first.update(status: :used, trip_id: @trip.id)
      end

      def create_trip
        @trip = Trip.create(data.to_h.except(:bonus, :card_id, :id, :status, :created_at, :idle, :car_id, :driver_id, :finished_at, :arrived_at, :started_at, :feedbacks, :delivery, :order_id))
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::SearchCarForTrip.perform_later(trip_id)
      end

      def approve_by_vendor
        @order.vendor.need_approve ? send_message_to_vendor : Events::Trips::UpdateStatus.(trip_id: @order.trip_id)
      end

      def send_message_to_vendor
        Jobs::TelegramNotification.perform_later(@order.vendor.telegram_account, data[:time], @order.items, @order.user.phone_number, @order.id, data[:comment].split('Коментар користувача: ')[-1])
      end

      def bonus_trips
        @bonus_trips ||= User.find(data[:user_id]).bonus_trips.fresh
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

      def delivery?
        data[:delivery].present?
      end

      def update_trip_time
        data[:time] = (data[:time].in_time_zone - data[:duration].seconds).strftime('%H:%M')
      end
    end
  end
end
