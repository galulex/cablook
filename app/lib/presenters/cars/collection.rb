class Presenters::Cars::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Cars::Single, as: :cars
end
