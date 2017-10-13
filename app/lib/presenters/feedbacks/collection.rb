class Presenters::Feedbacks::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Feedbacks::Single, as: :feedbacks
end
