module Jobs
  class NotifyUsers < ActiveJob::Base
    def perform
      batch_size = 1
      offset = 0
      loop do
        trips = Trip.select('distinct on (user_id) trips.*').unpaid.limit(batch_size).offset(offset)
        trips.each do |trip|
          Events::Users::Notify.(trip_id: trip.id)
        end
        break if trips.size < batch_size
        offset += batch_size
        sleep(1.hour)
      end
      Redis.current.set("button_state", false)
    end
  end
end
