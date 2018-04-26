module Api
  module DriversApp
    class MapsController < Api::DriversApp::ApplicationController
      def index
        cars = Repositories::Car.new(ROM.env).all_with_driver.map do |car_struct|
          location = redis.get("car_#{car_struct.id}")
          car = car_struct.to_h
          car[:location] = location&.split(',')
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
