module Api
  class CardsController < ApiApplicationController
    before_action :authorize!, except: :complete

    def index
      render json: { cards: cards }, status: 200
    end

    def new
      render json: Events::Cards::New.(user_id: current_user.id), status: 200
    end

    def destroy
      event = Events::Cards::Delete.(card_id: params[:id].to_i, user_id: current_user.id)
      raise Constants::NotFoundError unless event

      render json: { cards: cards }, status: 200
    end

    def complete
      Events::Cards::Create.(user_id: params[:merchant_data].to_i, order_id: params[:order_id],
                              sender_email: params[:sender_email], rectoken: params[:rectoken],
                              card_type: params[:card_type], masked_card: params[:masked_card],
                              currency: params[:currency] )
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
