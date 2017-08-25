module Validators
  class User
    include ROM::Model::Validator
    relation :users

    validates :email, uniqueness: true
  end
end
