module SearchEngine
  def self.call(trip_id:)
    cars = Car.where.not(status: Constants::Car::OFFLINE).pluck(:id)
    Operations::BroadcastTripProposal.(cars: cars, trip_id: trip_id)
  end
end