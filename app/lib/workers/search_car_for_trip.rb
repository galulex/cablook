module Workers
  class SearchCarForTrip
    include Sidekiq::Worker

    def perform(trip_id)
      SearchEngine.call(trip_id: trip_id)
    end
  end
end
