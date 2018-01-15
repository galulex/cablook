module Api
  module DriversApp
    class AssignCarController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def update
        driver = Events::DriversApp::AssignCar.(driver_params)
        render json: { driver: driver }
      end

      private

      def driver_params
        params.require(:driver).permit(:name, :car_id).merge(
          driver_id: current_driver.id
        )
      end
    end
  end
end
