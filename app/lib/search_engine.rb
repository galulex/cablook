module SearchEngine
  # car varialbe looks like -> # { car_id: 1, duration: 600 }
  # TODO: create a car model class (look to dry-rb libraries)

  def self.call(trip_id:)
    car = FindCar.(trip_id: trip_id)
    if car
      AssignAndBroadcast.(car.merge(trip_id: trip_id))
    else
      SearchCarForTripJob.set(wait: 1.minute).perform_later(trip_id)
    end
  end
end
