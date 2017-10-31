class Drivers::CarsController < ApplicationController
  before_action :authorize!

  def index
    cars = Repositories::Car.new.free_cars
    Presenters::Cars::Collection.new(cars).to_json
  end
end
