module Api
  module DriversApp
    class StatisticsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        render json: { rate: rate, statistics: statistics, driver: driver }, status: 200
      end

      private

      def rate
        feedback = Feedback.avg_by_driver(current_driver.id)
        return feedback.today[0]&.rate unless feedback.respond_to?(period)

        feedback.send(period)[0]&.rate
      end

      def statistics
        stats = Payment.driver_statistics(current_driver.id)
        return stats.today unless stats.respond_to?(period)

        stats.send(period)
      end

      def driver
        Presenters::DriversApp::Driver::Single.new(current_driver)
      end

      def period
        params[:period]
      end
    end
  end
end
