class Tips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int

    associations do
      has_one :trip
    end
  end
end
