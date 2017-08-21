module Users
  class Relation < ROM::Relation[:sql]
    register_as :users
    schema(infer: true)
  end
end
