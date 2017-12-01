module Validators
  class Card
    include ROM::Model::Validator

    relation :cards

    validates :token, presence: true, uniqueness: true
    validates :pan, :user_id, presence: true
  end
end
