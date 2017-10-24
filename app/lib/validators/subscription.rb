module Validators
  class Subscription
    include ROM::Model::Validator

    relation :subscriptions

    validates :email, presence: true
  end
end
