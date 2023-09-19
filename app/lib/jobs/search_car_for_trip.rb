module Jobs
  class SearchCarForTrip < ActiveJob::Base
    def perform(trip_id)
      cars = Car.where.not(status: Constants::Car::OFFLINE).pluck(:id)
      Operations::BroadcastTripProposal.(trip_id:, cars:)
    end
  end
end
