module Api
  class TripsController < ApiApplicationController
    before_action :authorize!

    def index
      trips = Repositories::Trip.new(ROM.env).by_user(current_user.id)
      render json: Presenters::Trips::Collection.new(trips).to_json, status: 200
    end

    def show
      trip = Repositories::Trip.new(ROM.env).by_pk_with_feedbacks(params[:id])
      render json: Presenters::Trips::Single.new(trip).to_json, status: 200
    end

    def create
      trip = Events::CreateTrip.(trip_params)
      render json: Presenters::Trips::Single.new(trip).to_json, status: 201
    end

    def cancel
      Events::Trips::Cancel.(trip_id: params[:trip_id].to_i)
      render json: [I18n.t('trips.canceled')], status: 200
    end

    private

    def trip_params
      params.require(:trip)
            .permit(:path, :cost, :departure_address, :destination_address, departure: [], destination: [])
            .merge(user_id: current_user.id)
    end
  end
end
