module Api
  module DriversApp
    class DriverCardsController < Api::DriversApp::ApplicationController
      before_action :authorize!

      def show
        card_number = current_driver.card_number
        render json: { card_number: card_number }.to_json, status: 200
      end

      def update
        current_driver.update!(card_number: params[:card_number])
        render json: { card_number: current_driver.card_number }.to_json, status: 200
      end
    end
  end
end
