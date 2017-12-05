module Presenters
  module Cards
    class Collection < Presenters::BaseCollection
      collection :entries, extend: Presenters::Cards::Single, as: :cards
    end
  end
end
