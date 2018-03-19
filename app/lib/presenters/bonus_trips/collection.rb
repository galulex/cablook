module Presenters
  module BonusTrips
    class Collection < Presenters::BaseCollection
      include Representable::JSON::Collection

      items extend: Presenters::BonusTrips::Single
    end
  end
end
