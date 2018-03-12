class Trips < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :status, Types::Int
    attribute :path, Types::String
    attribute :cost, Types::Float

    attribute :departure, Types::PG::Array
    attribute :destination, Types::PG::Array
    attribute :departure_address, Types::String
    attribute :destination_address, Types::String

    attribute :estimated_end_time, Types::Time
    attribute :created_at, Types::Time

    attribute :user_id, Types::ForeignKey(:users)
    attribute :car_id, Types::ForeignKey(:cars)
    attribute :driver_id, Types::ForeignKey(:drivers)

    attribute :start_at, Types::Time
    attribute :finish_at, Types::Time
    attribute :started_at, Types::Time
    attribute :finished_at, Types::Time
    attribute :arrived_at, Types::Time
    attribute :distance, Types::Int
    attribute :duration, Types::Int
    attribute :comment, Types::String

    associations do
      has_many :feedbacks
      has_one :cars
      has_one :users
      has_one :drivers
    end

    primary_key :id
  end

  def detailed
    select_append(cars[:number].as(:car_number), drivers[:name].as(:driver_name), drivers[:name].as(:driver_phone_number))
      .left_join(:cars, id: Sequel[:trips][:car_id])
      .left_join(:drivers, id: Sequel[:trips][:driver_id])
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

  def with_feedbacks
    combine(:feedbacks)
  end
end
