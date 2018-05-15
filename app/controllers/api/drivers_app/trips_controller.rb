module Api
  module DriversApp
    class TripsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        trips = Repositories::Trip.new(ROM.env).pending
        render json: Presenters::Trips::Collection.new(trips).to_json, status: 200
      end

      def currents
        trips = Repositories::Trip.new(ROM.env).currents(current_driver.id)
        render json: Presenters::Trips::DetailedCollection.new(trips).to_json, status: 200
      end

      def cancel
        Events::Trips::Cancel.(trip_id: params[:trip_id].to_i, by_driver: true)
        render json: [I18n.t('trips.canceled')], status: 200
      end

      def accept
        attrs = {
          trip_id: params[:trip_id].to_i,
          driver_id: current_driver.id,
          car_id: current_driver.car_id
        }
        Events::Trips::Accept.(attrs)
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      def start
        Events::Trips::Start.(trip_id: params[:trip_id].to_i)
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      def finish
        Events::Trips::Finish.(trip_id: params[:trip_id].to_i)
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      def waiting_client
        Events::Trips::WaitingClient.(trip_id: params[:trip_id].to_i)
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      private

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).detailed(params[:trip_id])
      end
    end
  end
end
