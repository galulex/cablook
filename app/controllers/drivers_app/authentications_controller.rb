module DriversApp
  class AuthenticationsController < DriversApp::ApplicationController
    def create
      driver = Events::DriversApp::Authentication.(sign_in_params)
      render json: Presenters::DriversApp::SinglePrivate.new(driver).to_json, status: 201
    end

    private

    def sign_in_params
      params.require(:driver).permit(:username, :password)
    end
  end
end
