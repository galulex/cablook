module Events
  module Cards
    class Update < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:orderReference).filled(:str?)
          required(:recToken)
          required(:transactionStatus).filled(:str?)
        end
      end

      def run
        update_card unless card.nil?
        send_response if data[:transactionStatus] != 'Pending'
      end

      private

      def card
        @card ||= Card.find_by(token: data[:orderReference])
      end

      def update_card
        @card.update(token: data[:recToken])
      end

      def send_response
        { "orderReference": data[:orderReference],
          "status": 'accept',
          "time": Time.now.to_i,
          "signature": signature }
      end

      def signature
        OpenSSL::HMAC.hexdigest('MD5', "#{ENV['WAYFORPAY_SECRET']}", "#{data[:orderReference]};accept;#{Time.now.to_i}")
      end
    end
  end
end
