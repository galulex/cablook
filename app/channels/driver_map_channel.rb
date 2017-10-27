class DriverMapChannel < ApplicationCable::Channel
  def subscribed
    stream_from Constants::Channels::DRIVER_MAP
  end

  def receive(data)
    ActionCable.server.broadcast Constants::Channels::DRIVER_MAP, data
  end
end
