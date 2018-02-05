module Presenters
  module BonusTrips
    class Collection < Presenters::BaseCollection
      collection :entries, extend: Presenters::BonusTrips::Single, as: :bonus_trips
    end
  end
end
