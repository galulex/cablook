module Api
  class CardsController < ApiApplicationController
    before_action :authorize!

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

    private

    def cards
      @cards ||= Card.user_cards(current_user.id)
    end
  end
end
