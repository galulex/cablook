class Presenters::Trips::Detailed < Presenters::BaseSingle
  properties :id, :status, :path, :cost, :departure, :destination,
             :departure_address, :destination_address, :waypoints,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance, :comment,
             :user_id, :driver_id, :created_at, :stops,
             :driver_name, :car_number, :car_phone_number, :car_color,
             :user_number, :trips_count, :payment_status
  property :start_time, exec_context: :decorator
  property :finish_time, exec_context: :decorator

  def start_time
    represented.start_at.strftime('%H:%M')
  rescue
    nil
  end

  def finish_time
    (represented.start_at + represented.duration.seconds).strftime('%H:%M')
  rescue
    nil
  end
end
