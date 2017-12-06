module Jobs
  class SearchCarForTrip < ActiveJob::Base
    rescue_from(SearchEngine::NotFoundCarError) do
      retry_job wait: 1.minutes
    end

    def perform(trip_id)
      SearchEngine.call(trip_id: trip_id)
    end
  end
end
