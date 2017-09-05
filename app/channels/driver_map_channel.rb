class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::DRIVER_MAP_CHANNEL
  end

  def receive(data)
    ActionCable.server.broadcast Constants::DRIVER_MAP_CHANNEL, data
  end
end
