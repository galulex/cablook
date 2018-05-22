class Tips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :trip_id, Types::ForeignKey(:trips)
    attribute :amount, Types::Int
    attribute :response, Types::PG::JSONB

    associations do
      has_one :trip
    end
  end
end
