class TripChannel < ApplicationCable::Channel
  def subscribed
    stream_from trip_channel
  end

  def receive(data)
    if data.action == 'DriverLocationUpdated'
      ActionCable.server.broadcast(trip_channel, data, Car.find(JSON.parse(data.fetch('body')).fetch('car_id').as_json(methods: [:dis, :deg])))
    else
      ActionCable.server.broadcast trip_channel, data
    end
    # ActionCable.server.broadcast trip_channel, data
  end

  def waiting_client(data)
    Events::Trips::WaitingClient.(trip_id: params[:trip_id])
  end

  def start_trip(data)
    Events::Trips::Start.(trip_id: params[:trip_id])
  end

  def finish_trip(data)
    Events::Trips::Finish.(trip_id: params[:trip_id], idle: params[:idle])
  end

  private

  def trip_channel
    "#{Constants::Channels::TRIP}_#{params[:trip_id]}"
  end
end
