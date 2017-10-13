class Presenters::Drivers::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Drivers::Single, as: :drivers
end
