class TripsController < ApplicationController
  before_action :authorize!

  def index
    trips = Repositories::Trip.new.by_user(current_user.id)
    render json: { trips: trips }
  end

  def show
    trip = Repositories::Trip.new.by_pk_with_feedbacks(params[:id])
    render json: { trip: trip }
  end

  def create
    trip = Events::CreateTrip.(trip_params)
    render json: { trip: trip }
  end

  private

  def trip_params
    params.require(:trip).permit(:path, :cost).merge(user_id: current_user.id)
  end
end
