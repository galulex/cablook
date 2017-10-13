class Presenters::Trips::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Trips::Single, as: :trips
end
