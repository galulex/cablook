class Presenters::Drivers::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Drivers::SinglePublic, as: :drivers
end
