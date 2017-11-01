class Subscriptions < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :email, Types::String
    attribute :created_at, Types::Time

    primary_key :id
  end
end
