module Api
  module DriversApp
    class MapsController < Api::DriversApp::ApplicationController
      def index
        cars = Car.for_map.as_json(include: { driver: { only: %i[id name username] } }, methods: %w[location, position] )
        render json: { cars: cars }.to_json, status: 200
      end
    end
  end
end
