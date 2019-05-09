module Api
  class DevicesController < ApiApplicationController
    before_action :user

    def create
      Operations::UpdateUserDevice.(user.id, device_params)
      head 200
    end

    private

    def user
      @user ||= User.fetch_user(auth_token)[0]
      @user ? @user : (raise Constants::NotFoundError)
    end

    def device_params
      params[:device].permit(:token, :platform).to_h.symbolize_keys
    end
  end
end
