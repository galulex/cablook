module Api
  module DriversApp
    class DriversController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def update
        current_driver.update!(device_params)
        render json: {}, status: 200
      end

      private

      def device_params
        params.require(:device).permit(:device, :device_platform)
      end
    end
  end
end
