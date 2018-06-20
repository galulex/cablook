module Api
  module DriversApp
    class MapsController < Api::DriversApp::ApplicationController
      def index
        cars = Car.joins('INNER JOIN drivers ON drivers.car_id = cars.id').map do |car_model|
          location = redis.get("car_#{car_model.id}")
          car = car_model.attributes
          car['location'] = location&.split(',')
          car
        end
        render json: { cars: cars }.to_json, status: 200
      end

      private

      def redis
        @redis ||= Redis.current
      end
    end
  end
end
