module Api
  module DriversApp
    class DriversController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def update
        current_driver.update!(device: driver_params)
        render json: {}, status: 200
      end

      private

      def driver_params
        params.permit(:device)
      end
    end
  end
end
