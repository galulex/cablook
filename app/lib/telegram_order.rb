class TelegramOrder
  UPDATABLE_STEPS = { request_departure_address: :request_destination_address,
                      request_destination_address: :waypoints_confirmation,
                      waypoint: :waypoints_confirmation }.freeze
  METERS_IN_KILOMETERS = 1000

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def perform(command)
    send(command)
  end

  def start
    return send_message(:request_contact) unless @user.persisted?
    return send_message(:start) unless unpaid_trips?
    self.step = :trips_payment
    send_message(:unpaid_trips)
  end

  def send_message(action)
    reply(:send_message, action)
  end

  def reply(action, message, args = {})
    @user.reply(action, message, args)
  end

  def book
    self.trip = { telegram_trip: true }
    update_step(:request_departure_address)
  end

  def correct
    next_step = UPDATABLE_STEPS[step.to_sym]
    update_step(next_step) if next_step
  end

  def confirm_waypoints
    send_message(:request_waypoint_address)
    self.step = :initial_waypoint
  end

  def skip_comment
    self.trip = Events::Trips::Build.(trip.merge(user_id: @user.user_id)).as_json(methods: :image)
    update_trip(telegram_trip: true)
    @user.cards.size > 1 ? request_card : confirmation
  end

  def confirmation
    distance = trip[:distance] / METERS_IN_KILOMETERS
    reply(:send_photo, :trip_info, photo: trip[:image], message_options: { cost: trip[:cost], distance: distance })
    update_step(:confirm_trip)
  end

  def request_card
    reply(:send_message, :select_card, reply_markup: { keyboard: card_buttons })
    self.step = :select_card
  end

  def card_buttons
    @user.cards.map { |card| [{ text: card.pan }] }
  end

  def add_card(pan)
    update_trip(card_id: @user.cards.find_by(pan: pan).id)
    confirmation
  end

  def cancel
    self.trip = {}
    self.feedback = {}
    self.step = :start
    start
  end

  def try_again
    Events::Trips::Retry.(trip_id: trip[:id])
    update_step(:looking_for_car)
  end

  def go
    self.trip = Events::Trips::Create.(trip.except(:telegram_trip).merge(user_id: @user.user_id)).as_json(methods: :image)
    update_trip(telegram_trip: true)
    update_step(:looking_for_car)
  end

  def compose_feedback(args, next_step)
    update_feedback(args)
    update_step(next_step)
  end

  def create_feedback
    Events::Feedbacks::Create.(feedback.merge(trip_id: trip[:id], user_id: @user.user_id))
    cancel
  end

  def confirm_address
    send_message(trip[:destination] ? :waypoints_confirmation : :request_destination_address)
  end

  def confirm_card
    send_message(:card_added)
    start
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

  def add_waypoint(stop_address, stop_point)
    update_trip(stops: trip[:stops] || [] << stop_address, waypoints: trip[:waypoints] || [] << stop_point)
  end

  def remove_last_waypoint
    initialize_waypoints unless trip[:waypoints]
    update_trip(stops: trip[:stops][0...-1], waypoints: trip[:waypoints][0...-1])
  end

  def initialize_waypoints
    update_trip(stops: [], waypoints: [])
  end

  def step=(val)
    Redis.current.set("user_#{@user.id}_step", val)
  end

  def step
    @user.persisted? ? Redis.current.get("user_#{@user.id}_step") : 'start'
  end

  def driver_found(action, name, phone)
    self.step = action
    reply(:send_message, action, message_options: { name: name, phone_number: phone })
  end

  def unpaid_trips?
    Trip.unpaid.where(user_id: @user.user_id).any?
  end

  def successful_payment
    send_message(:successful_payment)
    start
  end

  def payment_declined
    send_message(:payment_declined)
    start
  end

  def self.send_order_message(chat_id, time, items, phone_number, order_id)
    formatted_items = ["🔸Отримане нове замовлення!🔸\n\nНомер замовлення: ##{order_id}\n\n🕑Час подачі: #{time}\n\n📝 Замовлення:\n"]
    items.each { |item_name, info| formatted_items << "#{item_name} - #{eval(info)['quantity']}шт.\n" }
    formatted_items << "\n📞 Номер телефону клієнта: [#{phone_number}](tel:#{phone_number})"
    Telegram.bot.send_message(chat_id: chat_id, text: formatted_items.join(''), parse_mode: 'Markdown')
  end
end
