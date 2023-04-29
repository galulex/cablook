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
        return fondy_verify_url if settings.fondy?
        return wfp_widget_params if settings.wayforpay?
      end

      def fondy_verify_url
        JSON.parse(Fondy::Verify.new(data[:current_user], data[:api_card_callback_url]).call)['response']['checkout_url']
      end

      def wfp_widget_params
        WFP.new(data[:current_user], data[:api_card_callback_url]).params
      end
      
    end
  end
end
