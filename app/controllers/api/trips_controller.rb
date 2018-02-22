module Api
  class TripsController < ApiApplicationController
    before_action :authorize!

    def index
      trips = Repositories::Trip.new(ROM.env).by_user_and_status(current_user.id, index_params)
      render json: Presenters::Trips::Collection.new(trips).to_json(user_options: { with_feedbacks: true }), status: 200
    end

    def show
      trip = Repositories::Trip.new(ROM.env).detailed(params[:id])
      render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
    end

    def create
      trip = Events::Trips::Create.(trip_params)
      render json: Presenters::Trips::Single.new(trip).to_json, status: 201
    end

    def cancel
      Events::Trips::Cancel.(trip_id: params[:trip_id].to_i)
      render json: [I18n.t('trips.canceled')], status: 200
    end

    private

    def index_params
      { status: params[:status], page: params[:page]&.to_i, per: params[:per]&.to_i }.compact
    end

    def trip_params
      params.require(:trip)
            .permit(:path, :cost, :departure_address, :destination_address, :bonus, :card_id, departure: [], destination: [])
            .merge(user_id: current_user.id)
    end
  end
end
