module Admin
  class CarsController < Admin::ApplicationController
    def index
      @cars = car_repository.all
    end

    def new; end

    def create
      car_repository.create(car_params)
      redirect_to admin_cars_path
    end

    def update
      car_repository.update(params[:id], car_params)
      redirect_to admin_cars_path
    end

    def destroy
      car_repository.delete(params[:id])
      redirect_to admin_cars_path
    end

    private

    def car_repository
      @car_repository ||= Repositories::Car.new(ROM.env)
    end

    def car_params
      params.require(:car).permit(:number).to_h.symbolize_keys
    end
  end
end

