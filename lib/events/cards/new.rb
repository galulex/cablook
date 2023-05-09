module Events
  module Cards
    class New < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:current_user)
          required(:api_card_callback_url)
        end
      end

      def run
        payment_system_response
      end

      private

      def payment_system_response
        return fondy_new_card_response if is_fondy_method?
        wayforpay_new_card_response
      end

      def is_fondy_method?
        settings.fondy? && settings.is_allowed_for_fondy?(data[:current_user].phone_number)
      end

      def fondy_new_card_response
        payload = Fondy::Verify.new(data[:current_user], data[:api_card_callback_url]).call[:checkout_url]
        { method: :fondy, payload: payload }
      end

      def wayforpay_new_card_response
        payload = WFP.new(data[:current_user], data[:api_card_callback_url]).params
        { method: :wayforpay, payload: payload }
      end

      def settings
        @settings = Settings.get
      end
    end
  end
end
