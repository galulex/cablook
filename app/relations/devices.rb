class Devices < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :token, Types::String
    attribute :platform, Types::String

    attribute :user_id, Types::ForeignKey(:users)

    associations do
      belongs_to :user
    end

    primary_key :id
  end
end
