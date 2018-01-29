module Jobs
  class DeclineTrip < ActiveJob::Base
    def perform(trip_id)
      Events::Trips::Decline.(trip_id: trip_id)
    end
  end
end
