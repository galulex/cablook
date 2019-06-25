module Api
  module V2
    class TripsController < ApiApplicationController
      before_action :authorize_user_or_driver!

      def new
        trip = Events::Trips::Build.(trip_params)
        render json: Presenters::Trips::Single.new(trip).to_json, status: 200
      end

      private

      def trip_params
        params.require(:trip).permit!
      end
    end
  end
end
