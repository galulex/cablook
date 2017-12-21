module Jobs
  class SearchCarForTrip < ActiveJob::Base
    retry_on SearchEngine::NotFoundCarError, wait: 40.seconds, attempts: 10

    def perform(trip_id)
      SearchEngine.call(trip_id: trip_id)
    end
  end
end
