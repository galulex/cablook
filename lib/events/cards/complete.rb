module Events
  module Cards
    class Complete < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:params)
        end
      end

      def run
        create_fondy_card if settings.fondy?
        update_wayfor_pay_card if settings.wayforpay?
      end

      private

      def params
        @params ||= data[:params]
      end

      def update_wayfor_pay_card
        validate_wayforpay_params!
        update_card unless card.nil?
        send_response if params[:transactionStatus] != 'Pending'
      end

      def create_fondy_card
        Events::Cards::Create.(user_id: params[:merchant_data].to_i, email: params[:sender_email],
                                recToken: params[:rectoken], cardType: params[:card_type].downcase.capitalize,
                                cardPan: card_pan, currency: params[:currency] )
      end

      def card_pan
        "#{params[:masked_card].first(2)}****#{params[:masked_card].last(4)}"
      end

      def validate_wayforpay_params!
        invalid!('Invalid params') if params[:orderReference].blank? || params[:recToken].blank? || params[:transactionStatus].blank?
      end

      def card
        @card ||= Card.find_by(token: params[:orderReference])
      end

      def update_card
        @card.update(token: params[:recToken])
      end

      def send_response
        { "orderReference": params[:orderReference],
          "status": 'accept',
          "time": Time.now.to_i,
          "signature": signature }
      end

      def signature
        OpenSSL::HMAC.hexdigest('MD5', "#{ENV['WAYFORPAY_SECRET']}", "#{params[:orderReference]};accept;#{Time.now.to_i}")
      end
    end
  end
end
