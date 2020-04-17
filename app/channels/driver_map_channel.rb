class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def sos(data)
    data['action'] = Constants::BroadcastActions::SOS
    body = JSON.parse(data.fetch('body'))
    car = Car.find(body.fetch('car_id'))
    message = "SOS!\nВодій: #{car.driver&.name}"
    ActionCable.server.broadcast(Constants::Channels::DRIVER_MAP, data)
    Jobs::TelegramSendMessage.perform_later(ENV['SOS_CHAT_ID'], message)
  end

  def send_location(data)
    body = JSON.parse(data.fetch('body'))
    car_id = body.fetch('car_id')
    car = Car.find(car_id)
    car.location = [body.fetch('latitude'), body.fetch('longitude')]
    ActionCable.server.broadcast(
      Constants::Channels::DRIVER_MAP,
      action: Constants::BroadcastActions::SEND_LOCATION,
      car_id: car_id,
      location: car.location,
      speed: body['speed'],
      car: Presenters::Cars::Single.new(car).as_json
    )
    car.trips.current.each do |trip|
      ActionCable.server.broadcast(
        "#{Constants::Channels::TRIP}_#{trip.id}",
        action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
        body: {
          car_id: car_id,
          location: {
            latitude: car.location[0],
            longitude: car.location[1]
          },
          car: Presenters::Cars::Single.new(car).as_json
        }
      )
    end
    return unless body.dig('speed') > Constants::Car::MAX_SPEED
    message = "Водій перевищив швидкість!\nВодій: #{car.driver&.name}\nШвидкість: #{body.fetch('speed')}"
    Jobs::TelegramSendMessage.perform_later(ENV['SPEED_CHAT_ID'], message)
  end

  def accept_trip(data)
    body = JSON.parse(data.fetch('body'))
    Events::Trips::Accept.(body.symbolize_keys)
  rescue Events::InvalidParamsError
    # Bad parameters
  end
end
