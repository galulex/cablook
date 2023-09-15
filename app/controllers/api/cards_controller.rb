module Api
  class CardsController < ApiApplicationController
    before_action :authorize!, except: :complete

    def index
      render json: { cards: cards }, status: 200
    end

    def new
      render json: Events::Cards::New.(current_user: current_user, api_card_callback_url: api_card_callback_url)
    end

    # https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
    # params: spec/fixtures/card_callback.json
    def create
      card = Events::Cards::Create.(params.permit!.merge(user_id: current_user.id, recToken: params[:recToken] || params[:orderReference]))
      card ? (render json: cards.to_json, status: 200) : (head :unprocessable_entity)
    end

    def destroy
      event = Events::Cards::Delete.(card_id: params[:id].to_i, user_id: current_user.id)
      raise Constants::NotFoundError unless event

      render json: { cards: cards }, status: 200
    end

    def complete
      Events::Cards::Complete.(params: params)
      redirect_to root_path
    end

    def update
      current_user.cards.update_all("\"default\" = (id = #{params[:id]})")
      render json: cards.to_json, status: 200
    end

    private

    def cards
      @cards ||= Card.user_cards(current_user.id)
    end
  end
end
