module Events
  module NotificationSettings
    class Update < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:notification_settings).value(:array?, min_size?: 0) { each(:str?) }
          required(:user_id).filled(:int?)
        end
      end

      def run
        update_user_notification_settings
      end

      private

      def user
        @user ||= User.find_by(id: data[:user_id])
      end

      def update_user_notification_settings
        user.update(notification_settings: Constants::User::NOTIFICATIONS - data[:notification_settings])
      end
    end
  end
end

