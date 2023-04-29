module Api
  module DriversApp
    class RegistrationsController < Api::DriversApp::ApplicationController
      def create
        driver = Events::Drivers::Create.(driver_attrs)
        render json: Presenters::DriversApp::SinglePrivate.new(driver).to_json, status: 201
      end

      private

      def driver_attrs
        {
          name: driver_params[:name],
          username: driver_params[:username],
          card_number: driver_params[:card_number],
          encrypted_password: BCrypt::Password.create(driver_params[:password])
        }
      end

      def driver_params
        params.require(:driver).permit(:name, :username, :password, :card_number)
      end
    end
  end
end
