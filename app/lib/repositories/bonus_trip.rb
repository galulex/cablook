module Repositories
  class BonusTrip < ROM::Repository[:bonus_trips]
    commands :create, update: :by_pk, delete: :by_pk

    def by_id(id)
      bonus_trips.by_pk(id).one
    end

    def by_user(user_id)
      bonus_trips.combine(:user, :friend).where(user_id: user_id).to_a
    end

    def available_by_user(user_id)
      bonus_trips.where(user_id: user_id, status: Constants::BonusTrip::NEW).to_a
    end

    def by_friend(friend_id)
      bonus_trips.combine(:user, :friend).where(friend_id: friend_id).to_a
    end

    def frozen_by_friend(friend_id)
      bonus_trips.where(friend_id: friend_id, status: Constants::BonusTrip::FROZEN).to_a
    end

    def by_trip(trip_id)
      bonus_trips.where(trip_id: trip_id).one
    end
  end
end
