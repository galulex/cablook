class Trips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int.meta(primary_key: true)
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
      has_one :cars
      has_one :users
      has_one :drivers
    end

    primary_key :id
  end

  def active
    where(status: Constants::Trip::DRIVING)
  end

  def estimated_end_in_timeframe(from, till)
    where(Sequel.lit('estimated_end_time BETWEEN :from AND :till', from: from, till: till))
  end

  def with_car
    select_append(
      cars[:status].as(:car_status),
      cars[:number].as(:car_number)
    ).inner_join(:cars, id: Sequel[:trips][:car_id])
  end

  def with_user
    select_append(users[:phone_number].as(:user_number))
      .inner_join(:users, id: Sequel[:trips][:user_id])
  end
end
