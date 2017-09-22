module Validators
  class Feedback
    include ROM::Model::Validator

    relation :feedbacks

    validates :rate, :trip_id, :user_id, presence: true
  end
end
