class Presenters::Trips::Detailed < Presenters::BaseSingle
  properties :id, :status, :path, :cost, :departure, :destination,
             :departure_address, :destination_address, :waypoints,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance, :comment,
             :user_id, :driver_id, :created_at, :stops, :entrance, :no_call, :pre_order, :vip
  property :start_time, exec_context: :decorator
  property :finish_time, exec_context: :decorator

  property :bonus, exec_context: :decorator
  property :driver_name, exec_context: :decorator
  property :car_number, exec_context: :decorator
  property :car_phone_number, exec_context: :decorator
  property :car_color, exec_context: :decorator
  property :payment_status, exec_context: :decorator
  property :status, exec_context: :decorator
  property :trips_count, exec_context: :decorator
  property :user_number, exec_context: :decorator
  property :car_location, exec_context: :decorator
  property :car_position, exec_context: :decorator
  property :card_id, exec_context: :decorator
  property :car, decorator: Presenters::Cars::Single

  def card_id
    represented.payments.last&.card_id
  end

  def driver_name
    represented.try(:driver_name) || represented.driver&.name
  end

  def car_number
    represented.try(:car_number) || represented.car&.number
  end

  def car_phone_number
    represented.try(:car_phone_number) || represented.car&.phone_number
  end

  def car_color
    represented.try(:car_color) || represented.car&.color
  end

  def payment_status
    represented.try(:payment_status) || represented.trip_payment&.status
  end

  def bonus
    represented.bonus_trip.present?
  end

  def status
    Trip.statuses[represented.status]
  end

  def trips_count
    represented.try(:trips_count) || represented.user.trips_count
  end

  def user_number
    represented.try(:user_number) || represented.user.phone_number
  end

  def start_time
    represented.start_at.strftime('%d/%m') > Time.now.strftime('%d/%m') ? represented.start_at.strftime('%d/%m, %H:%M') : represented.start_at.strftime('%H:%M')
  rescue
    nil
  end

  def finish_time
    (represented.start_at + represented.duration.seconds).strftime('%H:%M')
  rescue
    nil
  end

  def car_location
    Redis.current.get("car_#{represented.car&.id}")&.split(",")&.reverse || [0, 0]
  end

  def car_position
    Redis.current.get("position_#{represented.car&.id}")&.split(",")&.reverse || [0, 0]
  end
end
