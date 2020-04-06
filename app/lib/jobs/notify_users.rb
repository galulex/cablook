module Jobs
  class NotifyUsers < ActiveJob::Base
    def perform(trip_ids)
      trips = Trip.where(id: trip_ids)
      trips.each_slice(90) do |trips_group|
        trips_group.each do |trip|
          Events::Users::Notify.(trip_id: trip.id)
        end
        sleep(1.hours)
      end
      Redis.current.set("button_state", false)
    end
  end
end
