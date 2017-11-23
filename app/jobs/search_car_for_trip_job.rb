class SearchCarForTripJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    SearchEngine.call(trip_id: trip_id)
  end
end
