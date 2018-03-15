class BonusTrips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :status, Types::Int
    attribute :user_id, Types::ForeignKey(:users)
    attribute :friend_id, Types::ForeignKey(:users)
    attribute :trip_id, Types::ForeignKey(:trips)
    attribute :code, Types::String
    attribute :type, Types::String

    associations do
      belongs_to :user, as: :user, foreign_key: :user_id
      belongs_to :user, as: :friend, foreign_key: :friend_id
      belongs_to :trip, foreign_key: :trip_id
    end

    primary_key :id
  end
end
