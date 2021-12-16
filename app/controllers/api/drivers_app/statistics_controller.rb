module Api
  module DriversApp
    class StatisticsController < Api::DriversApp::ApplicationController
      def index
        render json: { statistics: statistics }, status: 200
      end

      private

      def statistics
        current_driver.trips.statistics('driver_id').send(params[:period]).first
      end
    end
  end
end
