class TelegramOrder
  def initialize(user)
    @user = user
  end

  def perform(command)
    send(command)
  end

  def start
    send_message(@user.persisted? ? :start : :request_contact)
    self.step = :book
  end

  def send_message(action)
    @user.reply(:send_message, action)
  end

  def send_location(location)
    @user.reply(:send_location, :confirm_address, latitude: location['lat'], longitude: location['lng'])
  end

  def send_photo(photo)
    @user.reply(:send_photo, :confirm_trip, photo: photo)
  end

  def book
    self.step = :request_departure_address
    send_message :request_departure_address
  end

  def correct
    case step
    when 'request_departure_address'
      self.step = :request_destination_address
      send_message :request_destination_address
    when 'request_destination_address'
      self.trip = Events::Trips::Build.(trip.merge(user_id: @user.user_id, comment: '')).as_json(methods: :image)
      send_photo(trip[:image])
      send_message :confirm_trip
      self.step = :confirm_trip
    end
  end

  def cancel
    self.trip = {}
    self.feedback = {}
    self.step = :start
    send_message(:start)
  end

  def try_again
    Events::Trips::Retry.(trip_id: trip[:id])
    self.step = :looking_for_car
    send_message :looking_for_car
  end

  def go
    self.trip = Events::Trips::Create.(trip.merge(user_id: @user.user_id, comment: '')).as_json(methods: :image)
    self.step = :looking_for_car
    send_message :looking_for_car
  end

  def compose_feedback(args, next_step)
    update_feedback(args)
    send_message(next_step)
    self.step = next_step
  end

  def create_feedback
    Events::Feedbacks::Create.(feedback.merge(trip_id: trip[:id], user_id: @user.user_id))
    start
  end

  def confirm_address
    send_message(trip[:destination] ? :waypoints_confirmation : :request_destination_address)
  end

  def update_step(step)
    send_message(step)
    self.step = step
  end

  def trip
    JSON.parse(Redis.current.get("trip_#{@user.id}") || '{}', symbolize_names: true)
  end

  def trip=(attrs)
    Redis.current.set("trip_#{@user.id}", attrs.to_json)
  end

  def feedback
    JSON.parse(Redis.current.get("feedback_#{@user.id}") || '{}', symbolize_names: true)
  end

  def feedback=(attrs)
    Redis.current.set("feedback_#{@user.id}", attrs.to_json)
  end

  def update_feedback(args)
    self.feedback = feedback.merge(args)
  end

  def update_trip(args)
    self.trip = trip.merge(args)
  end

  def step=(val)
    Redis.current.set("user_#{@user.id}_step", val)
  end

  def step
    Redis.current.get("user_#{@user.id}_step") || 'start'
  end
end
