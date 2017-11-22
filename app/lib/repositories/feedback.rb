module Repositories
  class Feedback < ROM::Repository[:feedbacks]
    commands :create

    def by_trip(trip_id)
      feedbacks.where(trip_id: trip_id).to_a
    end
  end
end
