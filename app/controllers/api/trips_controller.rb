module Api
  class TripsController < ApiApplicationController
    before_action :authorize!

    def index
      render json: Presenters::Trips::Collection.new(trips).to_json(user_options: { with_feedbacks: true, without_vip: true }), status: 200
    end

    def show
      trip = Trip.find(params[:id])
      render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
    end

    def create
      trip = Events::Trips::Create.(trip_params.merge(user_id: current_user.id))
      render json: Presenters::Trips::Single.new(trip).to_json, status: 201
    end

    def cancel
      Events::Trips::Cancel.(trip_id: params[:trip_id].to_i)
      render json: [I18n.t('trips.canceled')], status: 200
    end

    def retry
      trip = Events::Trips::Retry.(trip_id: params[:trip_id].to_i)
      render json: Presenters::Trips::Single.new(trip).to_json, status: 200
    end

    def update
      trip = Events::Trips::Update.(trip_params)
      render json: Presenters::Trips::Detailed.new(trip).to_json, status: 200
    end

    def unpaid_trips
      unpaid = current_user.trips.unpaid
      render json: Presenters::Trips::Collection.new(unpaid).to_json, status: 200
    end

    private

    def trips
      Trip
        .except(:vip)
        .includes(:feedbacks, :bonus_trip, :user)
        .where(user_id: current_user.id, status: params[:status] || Constants::Trip::STATUSES)
        .order(id: :desc)
        .offset(index_params[:page]&.send(:*, index_params[:per]))
        .limit(index_params[:page].nil? ? nil : index_params[:per])
    end

    def index_params
      { page: params[:page]&.to_i, per: (params[:per] || 5).to_i }
    end

    def trip_params
      params.require(:trip).permit!
    end
  end
end
