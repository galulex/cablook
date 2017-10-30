module Validators
  class Driver
    include ROM::Model::Validator

    relation :drivers

    validates :username, presence: true, uniqueness: true
    validates :name, :encrypted_password, presence: true
  end
end
