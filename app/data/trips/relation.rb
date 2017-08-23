module Trips
  class Relation < ROM::Relation[:sql]
    register_as :trips
    schema(infer: true)
  end
end
