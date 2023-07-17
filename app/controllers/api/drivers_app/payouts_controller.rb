module Api
  module DriversApp
    class PayoutsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def create
        success = Operations::Fondy::DriverPayOut.new(current_driver, params[:amount].to_i).call
        render json: { driver: driver }, status: success ? 201 : 422
      end

      private

      def driver
        Presenters::DriversApp::Driver::Single.new(current_driver)
      end
    end
  end
end
