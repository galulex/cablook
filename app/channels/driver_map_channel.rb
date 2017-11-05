class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def send_location(data)
    body = JSON.parse(data['body'])
    location = [body.fetch('latitude'), body.fetch('longitude')]
    car_id = body.fetch('car_id')
    redis.set("car_#{car_id}", location)
  end

  private

  def redis
    @redis ||= Redis.new
  end
end
