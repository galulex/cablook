module Api
  module DriversApp
    class SessionsController < Api::DriversApp::ApplicationController
      def create
        driver = Events::DriversApp::Authorize.(sign_in_params)
        render json: driver.as_json.merge(cars: cars.as_json), status: 201
      end

      def destroy
        Events::DriversApp::SignOut.(driver_id: current_driver.id) if current_driver
        cookies.clear
        render json: {}, status: 200
      end

      private

      def cars
        @cars = Car.where(status: [Constants::Car::OFFLINE, Constants::Car::FREE], active: true)
      end

      def sign_in_params
        params.require(:driver).permit(:username, :password)
      end
    end
  end
end
