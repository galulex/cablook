module Api
  module DriversApp
    class TripsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        trips = Trip.where(status: Constants::Trip::PENDING)
        render json: Presenters::Trips::DetailedCollection.new(trips).to_json, status: 200
      end

      def currents
        trips = Trip.where(
          driver_id: current_driver.id,
          status: [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING, Constants::Trip::PRE_ORDERED]
        )
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
        Events::Trips::Finish.(trip_id: params[:trip_id].to_i, idle: params[:idle])
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      def waiting_client
        Events::Trips::WaitingClient.(trip_id: params[:trip_id].to_i)
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      private

      def trip
        @trip ||= Trip.find(params[:trip_id])
      end
    end
  end
end
