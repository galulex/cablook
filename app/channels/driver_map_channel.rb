class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def sos(data)
    return unless settings.sos

    data['action'] = Constants::BroadcastActions::SOS
    body = JSON.parse(data.fetch('body'))
    car = Car.find(body.fetch('car_id'))
    ActionCable.server.broadcast(Constants::Channels::DRIVER_MAP, data)
    Jobs::TelegramSendMessage.perform_later(ENV['SOS_CHAT_ID'], sos_message(car), car.location)
  end

  def send_location(data)
    body = JSON.parse(data.fetch('body'))
    speed = body.fetch('speed')
    car_id = body.fetch('car_id')
    car = Car.find(car_id)
    car.location = [body.fetch('latitude'), body.fetch('longitude')]
    broadcast_to_map_channel(car, speed)
    broadcast_to_trips_channels(car)
    send_overspeed(car, speed)
  end

  private

  def send_overspeed(car, speed)
    return unless settings.overspeed_notify && polygon.contains?(Geokit::LatLng.new(*car.location))

    max = redis.get("max_#{car.id}")
    if max && max.to_i > Constants::Car::MAX_SPEED && speed < Constants::Car::MAX_SPEED
      Jobs::TelegramSendMessage.perform_later(ENV['SPEED_CHAT_ID'], overspeed_message(car, max), car.location)
      redis.del("max_#{car.id}")
      return
    end
    return unless speed > Constants::Car::MAX_SPEED
    redis.set("max_#{car.id}", speed) if max.nil? || speed > max.to_i
   end

  def broadcast_to_map_channel(car, speed)
    ActionCable.server.broadcast(
      Constants::Channels::DRIVER_MAP,
      action: Constants::BroadcastActions::SEND_LOCATION,
      car_id: car.id,
      location: car.location,
      speed: speed,
      car: Presenters::Cars::Single.new(car).as_json
    )
  end

  def broadcast_to_trips_channels(car)
    location = car.location
    car.trips.current.each do |trip|
      ActionCable.server.broadcast(
        "#{Constants::Channels::TRIP}_#{trip.id}",
        action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
        body: {
          car_id: car.id,
          location: {
            latitude: location[0],
            longitude: location[1]
          },
          car: Presenters::Cars::Single.new(car).as_json
        }
      )
    end
  end

  def polygon
    @polygon ||= Geokit::Polygon.new(JSON.parse(File.read('config/polygons/cherkassy.json')).map { |point| Geokit::LatLng.new(point['lat'], point['lng']) })
  end

  def redis
    @redis ||= Redis.current
  end

  def sos_message(car)
    "🆘SOS!🆘\n🚕 #{car.number}\n👤 #{car.driver&.name}\n📞 [#{car.phone_number}](tel:#{car.phone_number})"
  end

  def overspeed_message(car, max)
    "🚨Водій перевищив швидкість!🚨\n🚕 #{car.number}\n👤 #{car.driver&.name}\n📞 [#{car.phone_number}](tel:#{car.phone_number})\n⚠ #{max} КМ/Г"
  end

  def settings
    @settings ||= Settings.get.feature
  end
end
