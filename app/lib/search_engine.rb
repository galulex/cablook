module SearchEngine
  # car varialbe looks like -> # { car_id: 1, duration: 600 }
  # TODO: create a car model class (look to dry-rb libraries)

  NotFoundCarError = Class.new(StandardError)

  def self.call(trip_id:)
    event = FindCar.(trip_id: trip_id)
    if event.is_a?(Hash)
      AssignAndBroadcast.(event.merge(trip_id: trip_id))
    elsif event.is_a?(Array)
      BroadcastPropose.(cars: event, trip_id: trip_id)
    else
      raise NotFoundCarError
    end
  end
end
