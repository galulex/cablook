module Events
  module Users
    class Update < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          required(:locale).filled(:str?)
        end
      end

      def run
        validate!
        user.save
      end

      private

      def validate!
        user.assign_attributes(locale: data[:locale])
        invalid!(user.errors.full_messages.flatten) if user.invalid?
      end

      def user
        @user ||= User.find_by(id: data[:user_id])
      end
    end
  end
end
