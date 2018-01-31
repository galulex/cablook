module Repositories
  class Trip < ROM::Repository[:trips]
    commands :create, update: :by_pk, delete: :by_pk

    def all
      trips.to_a
    end

    def by_id(trip_id)
      trips.by_pk(trip_id).one
    end

    def by_user(user_id, page: nil, per: 5)
      trips.where(user_id: user_id).order(Sequel.desc(:id)).offset(page&.send(:*, per)).limit(page.nil? ? nil : per).to_a
    end

    def by_pk_with_feedbacks(trip_id)
      trips.by_pk(trip_id).combine(:feedbacks).one
    end

    def active_and_estimated_end_in_timeframe(from: Time.now, till: Time.now + 5.minutes)
      trips.active.estimated_end_in_timeframe(from, till).to_a
    end

    def by_id_with_user(trip_id)
      trips.by_pk(trip_id).with_user.one
    end
  end
end
