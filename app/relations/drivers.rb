class Drivers < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    attribute :username, Types::String
    attribute :encrypted_password, Types::String
    attribute :auth_token, Types::String

    attribute :car_id, Types::ForeignKey(:cars)

    primary_key :id
  end
end
