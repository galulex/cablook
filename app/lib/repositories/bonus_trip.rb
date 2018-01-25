module Repositories
  class BonusTrip < ROM::Repository[:bonus_trips]
    commands :create, update: :by_pk

    def by_friend(friend_id)
      bonus_trips.where(friend_id: friend_id).to_a
    end
  end
end
