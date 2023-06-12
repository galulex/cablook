module Api
  module DriversApp
    class StatisticsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        render json: { statistics: statistics, driver: driver }, status: 200
      end

      private

      def statistics
        current_driver.trips.driver_statistics.send(params[:period]).first
      end

      def driver
        Presenters::DriversApp::Driver::Single.new(current_driver)
      end
    end
  end
end
