module Api
  class CardsController < ApiApplicationController
    before_action :authorize!, except: :update

    def index
      render json: { cards: cards }, status: 200
    end

    # https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
    # params: spec/fixtures/card_callback.json
    def create
      card = Events::Cards::Create.(params.merge(user_id: current_user.id, recToken: params[:recToken] || params[:orderReference]))
      card ? (render json: card.to_json, status: 200) : (head :unprocessable_entity)
    end

    def destroy
      event = Events::Cards::Delete.(card_id: params[:id].to_i, user_id: current_user.id)
      raise Constants::NotFoundError unless event
      head :ok
    end

    def update
      return head :unprocessable_entity unless parameters
      event = Events::Cards::Update.(orderReference: parameters['orderReference'], recToken: parameters['recToken'], transactionStatus: parameters['transactionStatus'])
      event ? (render json: event) : (head :not_modified)
    end

    private

    def cards
      @cards ||= Card.user_cards(current_user.id)
    end

    # Wayforpay send all params as one, which is key with nil value.
    def parameters
      return if params.keys.length < 3
      JSON.parse(params.keys.first)
    end
  end
end
