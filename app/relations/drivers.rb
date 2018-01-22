class Drivers < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    attribute :username, Types::String
    attribute :encrypted_password, Types::String
    attribute :auth_token, Types::String

    attribute :car_id, Types::ForeignKey(:cars)

    associations do
      belongs_to :car
    end

    primary_key :id
  end

  def with_car
    join(:cars).select_append(cars[:number])
  end
end
