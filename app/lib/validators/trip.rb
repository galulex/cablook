module Validators
  class Trip
    include ROM::Model::Validator

    relation :trips

    validates :path, :cost, :user_id, presence: true
  end
end
