module SearchEngine
  def self.call(trip_id:)
    car = FindCar.(trip_id: trip_id)
    if car
      # AssignAndBroadCast.(car.merge(trip_id))
    else
      # TODO: repeat job in 5 minutes
      # SearchJob.perform(trip_id)
    end
  end
end
