module Validators
  class Car
    include ROM::Model::Validator

    relation :cars

    validates :number, presence: true, uniqueness: true
  end
end
