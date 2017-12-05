module Events
  class CreateFeedback < BaseEvent
    def schema
      Dry::Validation.Schema do
        configure { config.messages = :i18n }

        required(:rate) { int? & gt?(0) & lteq?(5) }
        optional(:description).filled(:str?)
        required(:trip_id).filled(:int?)
        required(:user_id).filled(:int?)
      end
    end

    def run
      validate!
      create_feedback
    end

    private

    def validate!
      validator = Validators::Feedback.new(data)
      invalid!(validator.errors.values.flatten) if validator.invalid?
    end

    def create_feedback
      Repositories::Feedback.new(ROM.env).create(data.to_h)
    end
  end
end
