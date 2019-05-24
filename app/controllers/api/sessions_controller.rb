module Api
  class SessionsController < ApiApplicationController
    def create
      user = Events::Users::Authorize.(authorize_params)
      Operations::UpdateUserDevice.(user.id, device_params) if params[:device]
      # Temoporari until mobile app update
      # render json: user.as_json(except: %i[auth_token verification_token]), status: 201
      render json: user.as_json, status: 201
    end

    def update
      user = Events::Users::Verify.(params)
      render json: Presenters::Users::Verified.new(user).to_json
    end

    private

    def authorize_params
      params.permit(:phone_number, :firebase, :auth_token)
    end

    def device_params
      params[:device].permit(:token, :platform).to_h.symbolize_keys
    end
  end
end
