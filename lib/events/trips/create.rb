module Events
  module Trips
    class Create < BaseEvent
      include Concerns::Direction
      include Validations::Create

      FIELDS = %i[duration distance path].freeze

      def schema
        Dry::Schema.Params do
          required(:user_id).filled(:int?)
          required(:departure).filled
          required(:destination).filled
          required(:departure_address).filled(:str?)
          required(:destination_address).filled(:str?)

          optional(:order_data)
          optional(:cash)
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
        (settings.bonuses || settings.cashback) && bonus? ? pay_by_bonus : create_payment
        order_operations if delivery?
        create_trip_job(@trip.id) unless delivery?
        notify
        create_user_card if mobile_pay?
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
        @trip.update(comment: @trip.comment.prepend("Номер замовлення: ##{@order.id}. #{order_details}"))
      end

      def order_details
        details = "Сума: #{@order.amount}. Товари:"
        @order.items.values.each { |item| details << " #{eval(item)['name']} - #{eval(item)['quantity']}; " }
        details
      end

      def create_payment
        Payments::Trip.create(
          status: mobile_pay? ? Constants::Payments::SUCCESS : Constants::Payments::PENDING,
          amount: @trip.cost,
          user_id: @trip.user_id,
          card_id: mobile_pay? || cash_trip? ? nil : card.id,
          payment_method: payment_method,
          trip_id: @trip.id,
          order_reference: order_reference,
          response: cash_trip? ? { cash_trip: true } : hold_amount
        )
      end

      def pay_by_bonus
        Payments::Trip.create(
          status: Constants::Payments::BONUS,
          amount: 0,
          trip_id: @trip.id,
          card_id: card.id,
          user_id: data[:user_id]
        )
        if cashback?
          cashback_bonus_trip ? update_bonus_trip(cashback_bonus_trip) : create_cashback_trip
        else
          update_bonus_trip(bonus_trip)
        end
      end

      def create_trip
        @trip = Trip.create(data.to_h.except(:bonus, :cashback, :card_id, :id, :status, :created_at, :idle, :car_id, :driver_id, :finished_at, :arrived_at, :started_at, :feedbacks, :delivery, :order_id, :cash, :order_data))
        validate_hold_amount! if settings.fondy?
      end

      def hold_amount
        return mobile_payment_response if mobile_pay?

        return unless settings.fondy?

        @hold_amount ||= Fondy::Recurring.new(user, data[:cost], card.token, order_reference, true).call
      end

      def hold_success?
        hold_amount[:status]
      end

      def create_trip_job(trip_id)
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::SearchCarForTrip.perform_later(trip_id)
        return if !settings.fondy? || cash_trip?

        Jobs::RefundHoldedAmount.set(wait: Constants::Trip::REFUND_HOLD_IN).perform_later(trip_id, data[:cost], order_reference)
      end

      def approve_by_vendor
        @order.vendor_need_approve ? send_message_to_vendor : Events::Trips::UpdateStatus.(trip_id: @order.trip_id)
      end

      def notify
        return if @trip.user.notification_settings.include?(Constants::User::SEARCH_CAR)

        message = I18n.t('notification.loading')
        Jobs::Notification.perform_later(@trip, message)
        Jobs::DriversNotification.perform_later(@trip)
      end

      def send_message_to_vendor
        Jobs::TelegramNotification.perform_later(@order.vendor.telegram_account, data[:time], @order.items, @order.user.phone_number, @order.id, data[:comment].split('Коментар користувача: ')[-1])
      end

      def bonus_trips
        @bonus_trips ||= User.find(data[:user_id]).bonus_trips.fresh
      end

      def bonus_trip
        bonus_trips.where.not(type: Constants::BonusTrip::CASHBACK).first
      end

      def cashback_bonus_trip
        bonus_trips.where(type: Constants::BonusTrip::CASHBACK).first
      end

      def create_cashback_trip
        BonusTrip.create(
          user_id: user.id,
          trip_id: @trip.id,
          status: :used,
          code: SecureRandom.base58(24),
          type: Constants::BonusTrip::CASHBACK
        )
      end

      def update_bonus_trip(fresh_bonus_trip)
        fresh_bonus_trip.update(status: :used, trip_id: @trip.id)
      end

      def card
        card = user_cards.detect { |c| c.id == data[:card_id].to_i } if data[:card_id]
        card || user_cards.first
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
      end

      def create_user_card
        return if user.cards.exists?(token: order_data[:rectoken])

        Events::Cards::Create.(user_id: user.id,
                               cardPan: order_data[:masked_card][0, 2] + '*' * 4 + order_data[:masked_card][-4, 4],
                               recToken: order_data[:rectoken],
                               cardType: order_data[:card_type],
                               email: order_data[:sender_email])
      end

      def user
        @user ||= User.find(data[:user_id])
      end

      def bonus?
        data[:bonus].present?
      end

      def cashback?
        data[:cashback].present?
      end

      def delivery?
        data[:delivery].present?
      end

      def update_trip_time
        data[:time] = (data[:time].in_time_zone - data[:duration].seconds).strftime('%H:%M')
      end

      def order_reference
        @order_reference ||= mobile_pay? ? order_data[:order_id] : OrderReference.new(@trip.id).call
      end

      def payment_method
        return Constants::Payments::METHOD_MOBILE if mobile_pay?

        return Constants::Payments::METHOD_CASH if cash_trip?

        Constants::Payments::METHOD_CARD
      end

      def cash_trip?
        data[:cash] && !mobile_pay?
      end

      def mobile_pay?
        order_data.present? && mobile_payment_response_status
      end

      def order_data
        data[:order_data]
      end

      def mobile_payment_response
        { status: mobile_payment_response_status }.merge(order_data)
      end

      def mobile_payment_response_status
        order_data[:response_status] == Constants::Payments::FONDY_SUCCESS && order_data[:order_status] == Constants::Payments::FONDY_APPROVED
      end
    end
  end
end
