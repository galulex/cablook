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
  end

  def send_location(data)
    body = JSON.parse(data.fetch('body'))
    speed = body.fetch('speed')
    car_id = body.fetch('car_id')
    coords = [body.fetch('latitude').to_f, body.fetch('longitude').to_f]
    current_trips = body.fetch('current_trips', [])
    redis.set("car_#{car_id}", coords.join(','))
    redis.set("car_data_#{car_id}", { speed: speed, current_trips: current_trips }.to_json)
  end

  private

  def polygon
    @polygon ||= Geokit::Polygon.new(JSON.parse(File.read('config/polygons/cherkassy.json')).map { |point| Geokit::LatLng.new(point['lat'], point['lng']) })
  end

  def redis
    @redis ||= Redis.new
  end

  def sos_message(car)
    "🆘SOS!🆘\n🚕 #{car.number}\n👤 #{car.driver&.name}\n📞 [#{car.phone_number}](tel:#{car.phone_number})"
  end
end
