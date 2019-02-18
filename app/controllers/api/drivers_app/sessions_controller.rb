module Api
  module DriversApp
    class SessionsController < Api::DriversApp::ApplicationController
      before_action :authorize!, only: :destroy

      def create
        driver = Events::DriversApp::Authorize.(sign_in_params)
        render json: driver.as_json.merge(cars: cars.as_json), status: 201
      end

      def destroy
        Events::DriversApp::SignOut.(driver_id: current_driver.id)
        render json: {}, status: 200
      end

      private

      def cars
        @cars = Car.where(status: [Constants::Car::OFFLINE, Constants::Car::FREE])
      end

      def sign_in_params
        params.require(:driver).permit(:username, :password)
      end
    end
  end
end
