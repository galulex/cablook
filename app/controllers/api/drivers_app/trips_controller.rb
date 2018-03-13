module Api
  module DriversApp
    class TripsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        trips = Repositories::Trip.new(ROM.env).pending
        render json: Presenters::Trips::Collection.new(trips).to_json, status: 200
      end

      def cancel
        Events::Trips::Cancel.(trip_id: params[:trip_id].to_i, by_driver: true)
        render json: [I18n.t('trips.canceled')], status: 200
      end
    end
  end
end
