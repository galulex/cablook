module DriversApp
  class SessionsController < DriversApp::ApplicationController
    before_action :authorize!, only: :destroy

    def create
      driver = Events::DriversApp::Authorize.(sign_in_params)
      render json: Presenters::DriversApp::SinglePrivate.new(driver).to_json, status: 201
    end

    def destroy
      Events::DriversApp::SignOut.(driver_id: current_driver.id)
      render json: {}, status: 200
    end

    private

    def sign_in_params
      params.require(:driver).permit(:username, :password)
    end
  end
end
