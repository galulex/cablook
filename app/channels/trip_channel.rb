class TripChannel < ApplicationCable::Channel
  def subscribed
    stream_from trip_channel
  end

  def receive(data)
    ActionCable.server.broadcast trip_channel, data
  end

  def start_trip(data)
    Repositories::Trip.new(ROM.env).update(
      params[:trip_id],
      status: Constants::Trip::DRIVING,
      estimated_end_time: data[:estimated_end_time]
    )
  end

  def finish_trip(data)
    Repositories::Trip.new(ROM.env).update(
      params[:trip_id],
      status: Constants::Trip::FINISHED
    )
    # TODO: Wayforpay API call
  end

  private

  def trip_channel
    "#{Constants::Channels::TRIP}_#{params[:trip_id]}"
  end
end
