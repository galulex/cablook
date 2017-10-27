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
    attribute :car_id, Types::ForeignKey(:cars)
    attribute :driver_id, Types::ForeignKey(:drivers)

    associations do
      has_many :feedbacks
    end

    primary_key :id
  end

  def active
    where(status: Constants::Trip::DRIVING)
  end

  def estimated_end_in_timeframe(from, till)
    where(Sequel.lit('estimated_end_time BETWEEN :from AND :till', from: from, till: till))
  end

  def with_driver
    select_append(:drivers__car_id).inner_join(:drivers, id: :trips__driver_id)
  end
end
