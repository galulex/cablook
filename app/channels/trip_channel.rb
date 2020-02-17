class TripChannel < ApplicationCable::Channel
  def subscribed
    stream_from trip_channel
  end

  def receive(data)
    action = data['action'] || data['body']['action']
    if action == 'DriverLocationUpdated'
      car = Trip.find(params[:trip_id]).car
      data['body']['car'] = Presenters::Cars::Single.new(car).as_json
      ActionCable.server.broadcast(trip_channel, data)
    else
      ActionCable.server.broadcast trip_channel, data
    end
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
