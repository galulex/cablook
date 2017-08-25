module Feedbacks
  class Relation < ROM::Relation[:sql]
    register_as :feedbacks
    schema(infer: true)
  end
end
