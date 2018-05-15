class Presenters::Trips::DetailedCollection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Trips::Detailed, as: :trips
end
