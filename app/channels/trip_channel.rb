class TripChannel < ApplicationCable::Channel
  def subscribed
    stream_from trip_channel
  end

  def receive(data)
    ActionCable.server.broadcast trip_channel, data
  end

  private

  def trip_channel
    "#{Constants::Channels::TRIP}_#{trip_id}"
  end

  def trip_id
    params.fetch('data').fetch('trip_id')
  end
end
