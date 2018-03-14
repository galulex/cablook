module Api
  class CardsController < ApiApplicationController
    before_action :authorize!

    def index
      cards = Repositories::Card.new(ROM.env).by_user(current_user.id)
      render json: Presenters::Cards::Collection.new(cards).to_json, status: 200
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
  end
end
