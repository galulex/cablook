module Admin
  class TripsController < Admin::ApplicationController
    def index
      @trips = Repositories::Trip.new(ROM.env).all
    end

    def new
      @users = Repositories::User.new(ROM.env).all
    end

    def create
      Events::CreateTrip.(trip_params)
      redirect_to admin_trips_path
    rescue Events::InvalidParamsError
      # Bad params
      redirect_to admin_trips_path
    end

    def destroy
      Events::Trips::Cancel.(trip_id: params[:id].to_i)
      redirect_to admin_trips_path
    rescue Events::InvalidParamsError
      #Bad params
      redirect_to admin_trips_path
    end

    private

    def trip_params
      params.require(:trip)
            .permit(:path, :departure_address, :destination_address, departure: [], destination: [])
            .merge(cost: params[:trip][:cost].to_i, user_id: params[:trip][:user_id].to_i)
    end
  end
end
