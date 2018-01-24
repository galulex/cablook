module Repositories
  class BonusTrip < ROM::Repository[:bonus_trips]
    commands :create, update: :by_pk
  end
end
