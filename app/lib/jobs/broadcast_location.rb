require 'rest-client'
require 'json'

module Jobs
  # Contains tesla info from API
  class BroadcastLocation < ActiveJob::Base
    def perform(trip_id)
      trip = Trip.find(trip_id)
      while trip.current?
        Events::Cars::Broadcast.(trip: trip)
        sleep 3.seconds
        trip.reload
      end
    end
  end
end
