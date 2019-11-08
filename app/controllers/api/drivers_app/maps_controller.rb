module Api
  module DriversApp
    class MapsController < Api::DriversApp::ApplicationController
      def index
        cars = Car.for_map.as_json(include: { driver: { only: %i[id name username] } }, methods: %i[location position])
        render json: cars, status: 200
      end
    end
  end
end
