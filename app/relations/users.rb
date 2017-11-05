class Users < ROM::Relation[:sql]
  schema do
    attribute :id, Types::Int
    attribute :email, Types::String
    attribute :phone_number, Types::String
    attribute :encrypted_password, Types::String
    attribute :auth_token, Types::String
    attribute :confirmation_token, Types::String
    attribute :verification_token, Types::String

    primary_key :id
  end
end
