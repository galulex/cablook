module Api
  class SessionsController < ApiApplicationController
    def create
      user = Events::AuthorizeUser.(phone_number: params[:phone_number])
      render json: Presenters::Users::SinglePrivate.new(user).to_json, status: 201
    end

    def update
      user = Events::VerifyUser.(params)
      render json: Presenters::Users::Verified.new(user).to_json
    end
  end
end
