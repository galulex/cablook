class CardsController < ApplicationController
  before_action :authorize!

  def index
    cards = Repositories::Card.new(ROM.env).by_user(current_user.id)
    render json: Presenters::Cards::Collection.new(cards).to_json, status: 200
  end
end
