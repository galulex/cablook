class TripsController < ApplicationController
  before_action :authorize!

  def index
    trips = Repositories::Trip.new.by_user(current_user.id)
    Presenters::Trips::Collection.new(trips).to_json
  end

  def show
    trip = Repositories::Trip.new.by_pk_with_feedbacks(params[:id])
    Presenters::Trips::Single.new(trip).to_json
  end

  def create
    trip = Events::CreateTrip.(trip_params)
    Presenters::Trips::Single.new(trip).to_json
  end

  private

  def trip_params
    params.require(:trip).permit(:path, :cost).merge(user_id: current_user.id)
  end
end
