module Validators
  class Card
    include ROM::Model::Validator

    relation :cards

    validates :token, :pan, :user_id, presence: true
    validates :token, uniqueness: { scope: :user_id }
  end
end
