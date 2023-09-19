module Events
  module Users
    class Remove < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
        end
      end

      def run
        validate!
        validate_unpaid_trips!
        remove_account!
      end

      private

      def validate!
        invalid!(user.errors.full_messages.flatten) if user.invalid?
      end

      def validate_unpaid_trips!
        pending_payments = Trip.unpaid.where(user_id: data[:user_id])
        invalid!([I18n.t('trips.pay_off_debt')], status: 402) if pending_payments.any?
      end

      def remove_account!
        user.update!(deleted_at: Time.now)
      end

      def user
        @user ||= User.find_by(id: data[:user_id])
      end
    end
  end
end
