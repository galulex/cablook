class TripsController < ApplicationController
  before_action :authorize!

  def create
    trip = Events::CreateTrip.(trip_params)
    render json: { trip: trip }
  end

  private

  def trip_params
    params.require(:trip).permit(:path, :cost).merge(user_id: current_user.id)
  end
end
