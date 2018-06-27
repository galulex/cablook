module Api
  module DriversApp
    class CarsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        cars = Car.where(status: [Constants::Car::OFFLINE, Constants::Car::FREE])
        render json: Presenters::Cars::Collection.new(cars).to_json, status: 200
      end
    end
  end
end
