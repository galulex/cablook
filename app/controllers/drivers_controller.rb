class DriversController < ApplicationController
  before_action :authorize!

  def assign_car
    driver = Events::AssignCar.(driver_params)
    render json: { driver: driver }
  end

  private

  def driver_params
    params.require(:driver).permit(:name, :car_id).merge(
      driver_id: current_user.id
    )
  end
end
