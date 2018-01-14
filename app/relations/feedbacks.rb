class Feedbacks < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :rate, Types::Int
    attribute :description, Types::String
    attribute :user_id, Types::ForeignKey(:users)
    attribute :trip_id, Types::ForeignKey(:trip)

    primary_key :id
  end

end
