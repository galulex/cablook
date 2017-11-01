class Drivers::CarsController < ApplicationController
  before_action :authorize!

  def index
    cars = Repositories::Car.new.free_cars
    render json: Presenters::Cars::Collection.new(cars).to_json, status: 200
  end
end
