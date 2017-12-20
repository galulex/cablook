class TripJobs < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :activejob_id, Types::String
    attribute :sidekiq_id, Types::String

    attribute :trip_id, Types::ForeignKey(:trips)

    primary_key :id
  end
end
