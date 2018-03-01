module Api
  module DriversApp
    class TripsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def cancel
        Events::Trips::Cancel.(trip_id: params[:trip_id].to_i)
        render json: [I18n.t('trips.canceled')], status: 200
      end
    end
  end
end
