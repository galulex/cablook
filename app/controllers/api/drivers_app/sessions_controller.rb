module Api
  module DriversApp
    class SessionsController < Api::DriversApp::ApplicationController
      def create
        driver = Events::DriversApp::Authorize.(sign_in_params)
        cookies.encrypted[:token] = driver.auth_token
        render json: driver.as_json.merge(car: driver.car.as_json), status: 201
      end

      def destroy
        Events::DriversApp::SignOut.(driver_id: current_driver.id) if current_driver
        cookies.clear
        render json: {}, status: 200
      end

      private

      def sign_in_params
        params.require(:driver).permit(:username, :password)
      end
    end
  end
end
