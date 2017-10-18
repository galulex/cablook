module SearchEngine
  # car varialbe looks like -> # { car_id: 1, duration: 600 }
  # TODO: create a car model class (look to dry-rb libraries)

  def self.call(trip_id:)
    car = FindCar.(trip_id: trip_id)
    if car
      AssignAndBroadcast.(car.merge(trip_id))
    else
      # TODO: repeat job in 5 minutes
      SearchJob.set(wait: 5.min).perform_later(trip_id)
    end
  end
end
