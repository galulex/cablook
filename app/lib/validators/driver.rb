module Validators
  class Driver
    include ROM::Model::Validator

    relation :drivers

    validates :name, presence: true, uniqueness: true
  end
end
