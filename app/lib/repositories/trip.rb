module Repositories
  class Trip < ROM::Repository[:trips]
    relations :trips, :feedbacks

    commands :create

    def initialize
      super(ROM.env)
    end

    def by_user(user_id)
      trips.where(user_id: user_id).to_a
    end

    def by_pk_with_feedbacks(trip_id)
      trips.by_pk(trip_id).combine(many: feedbacks).one
    end
  end
end
