module Api
  class CardsController < ApiApplicationController
    before_action :authorize!, except: :update

    def index
      render json: { cards: cards }, status: 200
    end

    # https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
    # params: spec/fixtures/card_callback.json
    def create
      card = Events::Cards::Create.(params.merge(user_id: current_user.id))
      render json: Presenters::Cards::Single.new(card).to_json, status: 200
    end

    def destroy
      event = Events::Cards::Delete.(card_id: params[:id].to_i, user_id: current_user.id)
      raise Constants::NotFoundError unless event
      head :ok
    end

    def update
      return unless parameters
      if parameters[:recToken]&.empty? && !transaction_status
        head :not_modified
      else
        Events::Cards::Update.(parameters) unless transaction_status
        send_response
      end
    end

    private

    def cards
      @cards ||= Card.user_cards(current_user.id)
    end

    # Wayforpay send all params as one, which is key with nil value.
    def parameters
      return if params.keys.length < 3
      parsed_params = JSON.parse(params.keys.first)

      { orderReference: parsed_params['orderReference'],
        recToken: parsed_params['recToken'],
        transactionStatus: parsed_params['transactionStatus'] }
    end

    def update_signature
      OpenSSL::HMAC.hexdigest('MD5', "#{ENV['WAYFORPAY_SECRET']}", "#{parameters[:orderReference]};accept;#{Time.now.to_i}")
    end

    def transaction_status
      parameters[:transactionStatus] == 'Refunded' || parameters[:transactionStatus] == 'Expired'
    end

    def send_response
      render json: { "orderReference": parameters[:orderReference],
                     "status": 'accept',
                     "time": Time.now.to_i,
                     "signature": update_signature }
    end
  end
end
