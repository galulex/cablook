module Admin
  class CarsController < Admin::ApplicationController
    layout 'admin'

    before_action :car, only: %i[update destroy]

    def index
      @cars = Repositories::Car.new(ROM.env).all
    end

    def new
    end

    def edit
    end

    def create
      @car = Events::CreateCar.(car_params)
    end

    def update
    end

    def destroy
    end

    private

    def car
      @car ||= Repositories::Car.new(ROM.env).by_id(params[:id])
    end

    def car_params
      params.require(:car).permit(:number)
    end
  end
end
