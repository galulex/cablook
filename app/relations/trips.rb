class Trips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :status, Types::Int
    attribute :path, Types::String
    attribute :cost, Types::Float

    attribute :user_id, Types::ForeignKey(:users)
    attribute :driver_id, Types::ForeignKey(:drivers)

    associations do
      has_many :feedbacks
    end

    primary_key :id
  end
end
