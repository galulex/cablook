module Api
  class SessionsController < ApiApplicationController
    def verify_code
      user = User.find_by(email: verification_params[:email])
      if user.verification_code == verification_params[:code]
        user.update!(verification_code: nil)
        render json: user.as_json, status: 201
      else
        render json: { error: 'User not found or invalid code' }, status: 401
      end
    end

    def create
      user = Events::Users::Authorize.(authorize_params)
      Operations::UpdateUserDevice.(user.id, device_params) if params[:device]
      render json: user.as_json, status: 201
    end

    private

    def authorize_params
      params.permit(:phone_number, :auth_token, :locale, :email)
    end

    def device_params
      params[:device].permit(:token, :platform).to_h.symbolize_keys
    end

    def verification_params
      params.permit(:email, :code)
    end
  end
end
