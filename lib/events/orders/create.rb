module Events
  module Orders
    class Create < BaseEvent
      include Validations::Create

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          required(:vendor_id).filled(:int?)
          required(:card_id).filled(:int?)
          required(:trip_time).filled(:str?)

          required(:items).filled
        end
      end

      def run
        validate!
        validate_time!

        create_order
        return { valid: false } unless hold_money['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
        create_order_payment(Constants::Payments::HOLD)
        { valid: true, order_id: @order.id }
      end

      private

      def validate_time!
        time = Time.utc(2000, 1, 1, *data[:trip_time].split(':'))
        return if time.between?(vendor.open_at.utc.to_time, vendor.close_at.utc.to_time)

        invalid!([I18n.t('orders.vendor_closed')], status: 422)
      end

      def create_order
        @order ||= Order.create(
          user_id:   data[:user_id],
          vendor_id: data[:vendor_id],
          items:     data[:items],
          amount:    calculate_amount.to_i
        )
      end

      def hold_money
        @hold_money_response = Operations::Wayforpay::HoldMoney.new(user_card, @order.amount, order_reference).call
      end

      def create_order_payment(status)
        Payments::Order.create(
          user_id:         data[:user_id],
          card_id:         data[:card_id],
          order_id:        @order.id,
          amount:          @order.amount,
          response:        @hold_money_response,
          status:          status,
          order_reference: @order_reference
        )
      end

      def calculate_amount
        data[:items].to_h.sum do |order_item|
          order_item[1]['quantity'].to_i * order_item[1]['total_price'].to_f
        end
      end

      def vendor
        Vendor.find_by(id: data[:vendor_id])
      end

      def user_card
        Card.find_by(id: data[:card_id])
      end

      def user_cards
        @user_cards ||= Card.user_cards(data[:user_id])
      end

      def order_reference
        secure_code = SecureRandom.base58(6)
        @order_reference ||= if Rails.env.production?
                               "cablook_#{@order.id}_order_#{secure_code}"
                             else
                               "cablook_#{Rails.env}_#{@order.id}_order_#{secure_code}"
                             end
      end
    end
  end
end
