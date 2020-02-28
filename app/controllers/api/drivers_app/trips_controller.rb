module Api
  module DriversApp
    class TripsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def index
        trips = Trip.pending.order(:start_at, :preorder_time)
        render json: Presenters::Trips::DetailedCollection.new(trips).to_json, status: 200
      end

      #TODO Remove replace index with all and remove currents
      def all
        trips = Trip.for_driver(current_driver)
        render json: Presenters::Trips::DetailedCollection.new(trips).to_json, status: 200
      end

      def currents
        render json: Presenters::Trips::DetailedCollection.new(current_driver.trips.current).to_json, status: 200
      end

      def update
        trip = Events::Trips::Update.(trip_params.merge(by_driver: true))
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
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

      def payments_verify
        Operations::Wayforpay::DoPayment.new(trip.id, Constants::Payments::TYPES[:trip], nil).call
        render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
      end

      private

      def trip
        @trip ||= Trip.find(params[:trip_id])
      end

      def trip_params
        params.require(:trip).permit!
      end
    end
  end
end
