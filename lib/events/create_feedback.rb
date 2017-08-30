module Events
  class CreateFeedback < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:rate) { int? & gt?(0) & lteq?(5) }
        optional(:description).filled(:str?)
        required(:trip_id).filled(:int?)
        required(:user_id).filled(:int?)
      end
    end

    def run
      create_feedback
    end

    def create_feedback
      Repositories::Feedback.new.create(data.to_h)
    end
  end
end
