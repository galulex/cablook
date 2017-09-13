class Drivers < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    attribute :auth_token, Types::String

    primary_key :id
  end
end
