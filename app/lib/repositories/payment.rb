module Repositories
  class Payment < ROM::Repository[:payments]
    commands :create, update: :by_pk

    def by_trip(trip_id)
      payments.where(trip_id: trip_id).one
    end
  end
end
