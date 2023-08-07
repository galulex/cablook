module Api
  module DriversApp
    class StatisticsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        render json: { rate: rate, statistics: statistics, driver: driver }, status: 200
      end

      private

      def rate
        Feedback.avg_by_driver(current_driver.id).send(params[:period])[0]&.rate
      end

      def statistics
        Payment.driver_statistics(current_driver.id).send(params[:period])
      end

      def driver
        Presenters::DriversApp::Driver::Single.new(current_driver)
      end
    end
  end
end
