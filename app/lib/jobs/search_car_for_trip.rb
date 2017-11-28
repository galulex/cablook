module Jobs
  class SearchCarForTrip < ActiveJob::Base
    def perform(trip_id)
      SearchEngine.call(trip_id: trip_id)
    end
  end
end
