module Trips
  class Validator
    include ROM::Model::Validator

    relation :trips

    validates :path, :user_id, :cost, presence: true
  end
end
