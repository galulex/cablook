class Presenters::Users::CollectionPublic < Presenters::BaseCollection
  collection :entries, extend: Presenters::Users::SinglePublic, as: :users
end
