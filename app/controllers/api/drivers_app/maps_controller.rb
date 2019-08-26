module Api
  module DriversApp
    class MapsController < Api::DriversApp::ApplicationController
      def index
        # cars = Car.for_map.as_json(include: { driver: { only: %i[id name username] } }, methods: [:location, :position] )
        render json: cars, status: 200
      end

      private

      def cars
        url = URI('https://app.cablook.taxi/api/drivers_app/maps')
        res = Net::HTTP.get(url)
        ActiveSupport::JSON.decode(res)
      end
    end
  end
end
