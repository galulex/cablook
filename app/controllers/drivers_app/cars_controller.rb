module DriversApp
  class CarsController < DriversApp::ApplicationController
    before_action :authorize!

    def index
      cars = Repositories::Car.new(ROM.env).free_cars
      render json: Presenters::Cars::Collection.new(cars).to_json, status: 200
    end
  end
end
