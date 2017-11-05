class TripsController < ApplicationController
  before_action :authorize!

  def index
    trips = Repositories::Trip.new.by_user(current_user.id)
    render json: Presenters::Trips::Collection.new(trips).to_json, status: 200
  end

  def show
    trip = Repositories::Trip.new.by_pk_with_feedbacks(params[:id])
    render json: Presenters::Trips::Single.new(trip).to_json, status: 200
  end

  def create
    trip = Events::CreateTrip.(trip_params)
    render json: Presenters::Trips::Single.new(trip).to_json, status: 201
  end

  private

  def trip_params
    params.require(:trip)
          .permit(:path, :cost, departure: [], destination: [])
          .merge(user_id: current_user.id)
  end
end
