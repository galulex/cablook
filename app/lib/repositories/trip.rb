module Repositories
  class Trip < ROM::Repository[:trips]
    relations :trips, :feedbacks

    commands :create, update: :by_pk

    def initialize
      super(ROM.env)
    end

    def by_id(user_id)
      trips.by_pk(user_id).one
    end

    def by_user(user_id)
      trips.where(user_id: user_id).to_a
    end

    def by_pk_with_feedbacks(trip_id)
      trips.by_pk(trip_id).combine(many: feedbacks).one
    end

    def active_and_estimated_end_in_timeframe(from: Time.now, till: Time.now + 5.minutes)
      trips.active.estimated_end_in_timeframe(from, till).to_a
    end
  end
end
