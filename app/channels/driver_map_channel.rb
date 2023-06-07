class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def sos(data)
    return unless Settings.sos

    data['action'] = Constants::BroadcastActions::SOS
    body = JSON.parse(data.fetch('body'))
    car = Car.find(body.fetch('car_id'))
    ActionCable.server.broadcast(Constants::Channels::DRIVER_MAP, data)
    # Jobs::TelegramSendMessage.perform_later(ENV['SOS_CHAT_ID'], sos_message(car), car.location)
  end

  def send_location(data)
    body = JSON.parse(data.fetch('body'))
    speed = body.fetch('speed')
    car_id = body.fetch('car_id')
    coords = [body.fetch('latitude').to_f, body.fetch('longitude').to_f]
    current_trips = body.fetch('current_trips', [])
    redis.set("car_#{car_id}", coords.join(','))

    Jobs::BroadcastDriverLocation.perform_now(car_id, coords, speed, current_trips)
    send_overspeed(car_id, speed, coords) if speed > Constants::Car::MAX_SPEED
  end

  private

  def send_overspeed(car_id, speed, coords)
    return unless Settings.overspeed_notify && polygon.contains?(Geokit::LatLng.new(*car.location))

    max = redis.get("max_#{car_id}")
    if max && max.to_i > Constants::Car::MAX_SPEED && speed < Constants::Car::MAX_SPEED
      car = Car.find(car_id)
      # Jobs::TelegramSendMessage.perform_later(ENV['SPEED_CHAT_ID'], overspeed_message(car, max), car.location)
      redis.del("max_#{car_id}")
      return
    end
    return unless speed > Constants::Car::MAX_SPEED

    redis.set("max_#{car_id}", speed) if max.nil? || speed > max.to_i
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
end
