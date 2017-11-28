module SearchEngine
  # car varialbe looks like -> # { car_id: 1, duration: 600 }
  # TODO: create a car model class (look to dry-rb libraries)

  def self.call(trip_id:)
    event = FindCar.(trip_id: trip_id)
    if event.is_a?(Hash)
      AssignAndBroadcast.(event.merge(trip_id: trip_id))
    elsif event.is_a?(Array)
      BroadcastPropose.(cars: event, trip_id: trip_id)
    else
      Jobs::SearchCarForTrip.set(wait: 1.minute).perform_later(trip_id)
    end
  end
end
