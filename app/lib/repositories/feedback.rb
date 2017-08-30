module Repositories
  class Feedback < ROM::Repository[:feedbacks]
    relations :feedbacks

    commands :create

    def initialize
      super(ROM.env)
    end

    def by_trip(trip_id)
      feedbacks.where(trip_id: trip_id).to_a
    end
  end
end
