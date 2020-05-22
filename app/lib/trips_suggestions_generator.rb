class TripsSuggestionsGenerator
  def initialize(user, date)
    @user = user
    @date = date
  end

  def available_suggestions
    generated_suggestions = []
    previous_such_workday_trips = user_trips_for(date - 7.days)

    24.times do |index|
      hour_trips = previous_such_workday_trips.select do |trip|
        trip.started_at.hour == index
      end

      hour_trips.each do |previous_trip|
        generated_suggestions.push new_suggestion_object(previous_trip)
      end
    end

    generated_suggestions
  end
  
  private

  def user_trips_for(datetime)
    @user_trips_for ||= ::Trip.where(
      '(user_id = ?) AND (status = ?) AND (started_at BETWEEN ? AND ?)',
      user.id,
      Constants::Trip::FINISHED,
      date.beginning_of_day,
      date.end_of_day,
    )
  end

  def new_suggestion_object(previous_trip)
    suggested_start_at = date.change(hour: previous_trip.started_at.hour, min: previous_trip.started_at.to_datetime.minute, sec: 0) # Make it more suitable for taxi use cases
    {
      push_notification_timestamp: suggested_start_at.beginning_of_hour, 
      start_at: suggested_start_at,
      departure_address: previous_trip.departure_address,
      destination_address: previous_trip.destination_address,
    }
  end

  def minutes_of_hour_from_trip(object)
    (object.start_at || object.started_at).strftime('%M').to_i
  end

  attr_reader :user, :date
end