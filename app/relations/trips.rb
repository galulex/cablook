class Trips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :status, Types::Int
    attribute :path, Types::String
    attribute :cost, Types::Float

    attribute :departure, Types::PG::Array
    attribute :destination, Types::PG::Array

    attribute :estimated_end_time, Types::Time

    attribute :user_id, Types::ForeignKey(:users)
    attribute :driver_id, Types::ForeignKey(:drivers)

    associations do
      has_many :feedbacks
    end

    primary_key :id
  end

  def active
    where(status: 0)
  end

  def estimated_end_in_timeframe(from, till)
    # where { estimated_end_time.in(from..to) }
    where('estimated_end_time BETWEEN :from AND :till', from: from, till: till)
  end
end
