class Payments < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :amount, Types::Float
    attribute :status, Types::Int
    attribute :order_reference, Types::String

    attribute :card_id, Types::ForeignKey(:cards)
    attribute :trip_id, Types::ForeignKey(:trips)
    attribute :driver_id, Types::ForeignKey(:drivers)

    associations do
      belongs_to :card
      belongs_to :trip
      belongs_to :driver
    end

    primary_key :id
  end
end
