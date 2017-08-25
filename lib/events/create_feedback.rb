module Events
  class CreateFeedback < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:rate).filled(:int?)
        optional(:description).filled(:str?)
        required(:trip_id).filled(:int?)
        required(:user_id).filled(:int?)
      end
    end

    def run
      create_feedback
    end

    def create_feedback
      Feedbacks::Repository.new.create(data)
    end
  end
end
