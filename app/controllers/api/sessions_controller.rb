module Api
  class SessionsController < ApplicationController
    def create
      user = Events::AuthorizeUser.(phone_number: params[:phone_number])
      render json: Presenters::Users::SinglePrivate.new(user).to_json, status: 201
    end

    def update
      Events::VerifyUser.(params)
      render json: { messages: ['verified'] }
    end
  end
end
