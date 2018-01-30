class TripChannel < ApplicationCable::Channel
  def subscribed
    stream_from trip_channel
  end

  def receive(data)
    ActionCable.server.broadcast trip_channel, data
  end

  def waiting_client(data)
    Repositories::Trip.new(ROM.env).update(
      params[:trip_id],
      status: Constants::Trip::WAITING_CLIENT,
      arrived_at: Time.now
    )
    ActionCable.server.broadcast trip_channel, data.to_json
  end

  def start_trip(data)
    Repositories::Trip.new(ROM.env).update(
      params[:trip_id],
      status: Constants::Trip::DRIVING,
      estimated_end_time: data[:estimated_end_time],
      started_at: Time.now
    )
    ActionCable.server.broadcast trip_channel, data.to_json
  end

  def finish_trip(data)
    Repositories::Trip.new(ROM.env).update(
      params[:trip_id],
      status: Constants::Trip::FINISHED,
      finished_at: Time.now
    )
    # TODO: Impement logic when the price changed
    Jobs::PaymentSettle.perform_later(params[:trip_id])
    ActionCable.server.broadcast trip_channel, data.to_json
  end

  private

  def trip_channel
    "#{Constants::Channels::TRIP}_#{params[:trip_id]}"
  end
end
