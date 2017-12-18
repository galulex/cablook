module Repositories
  class TripJob < ROM::Repository[:trip_jobs]
    commands :create

    def by_trip_id(trip_id)
      trip_jobs.where(trip_id: trip_id).one
    end
  end
end
