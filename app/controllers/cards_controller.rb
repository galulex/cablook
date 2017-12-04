class CardsController < ApplicationController
  before_action :authorize!

  def index
    cards = Repositories::Card.new(ROM.env).by_user(current_user.id)
    render json: Presenters::Cards::Collection.new(cards).to_json, status: 200
  end

  # https://wiki.wayforpay.com/pages/viewpage.action?pageId=852102
  # params: spec/fixtures/card_callback.json
  def create
    Events::CreateCard.(params.merge(user_id: current_user.id))
  end
end
