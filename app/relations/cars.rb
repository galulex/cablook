class Cars < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :number, Types::String
    attribute :status, Types::Int

    primary_key :id
  end
end
