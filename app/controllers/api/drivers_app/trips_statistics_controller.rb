module Api
  module DriversApp
    class TripsStatisticsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        trips = current_driver.trips
                              .where(accepted_at: selected_day, status: :finished)
                              .includes(:user, :trip_payment, :driver, :payments, :car, :bonus_trip)
                              .order('id DESC')
        render json: Presenters::Trips::StatsCollection.new(trips).to_json, status: 200
      end

      private

      def selected_day
        date = Date.parse(params[:date])
        date.beginning_of_day..date.end_of_day
      end
    end
  end
end
