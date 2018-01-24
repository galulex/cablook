class Cars < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :number, Types::String
    attribute :status, Types::Int
    attribute :color, Types::String

    associations do
      has_one :driver
    end

    primary_key :id
  end

  def with_driver
    select_append(drivers[:id].as(:driver_id)).inner_join(:drivers)
  end
end
