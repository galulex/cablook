# The search_engine folder doesn't use now. Only this file

module SearchEngine
  def self.call(trip_id:)
    cars = Repositories::Car.new(ROM.env).online.map(&:id)
    Operations::BroadcastTripProposal.(cars: cars, trip_id: trip_id)
  end
end
