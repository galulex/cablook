module Validators
  class User
    include ROM::Model::Validator
    relation :users

    validates :email, allow_nil: true, uniqueness: true, format: { with: Constants::Regex::EMAIL }
    validates :phone_number, uniqueness: true, length: { is: 12 }
    validates :encrypted_password, presence: true
  end
end
