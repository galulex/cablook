class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def sos(data)
    data['action'] = Constants::BroadcastActions::SOS
    ActionCable.server.broadcast(Constants::Channels::DRIVER_MAP, data)
  end

  def send_location(data)
    body = JSON.parse(data.fetch('body'))
    location = [body.fetch('latitude'), body.fetch('longitude')]
    car_id = body.fetch('car_id')
    redis.set("car_#{car_id}", location.join(','))
    ActionCable.server.broadcast(
      Constants::Channels::DRIVER_MAP,
      action: Constants::BroadcastActions::SEND_LOCATION,
      car_id: car_id,
      location: location
    )
  end

  def accept_trip(data)
    body = JSON.parse(data.fetch('body'))
    Events::Trips::Accept.(body.symbolize_keys)
  rescue Events::InvalidParamsError
    # Bad parameters
  end

  private

  def redis
    @redis ||= Redis.current
  end
end
