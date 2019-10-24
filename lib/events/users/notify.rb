module Events
  module Users
    class Notify < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
        end
      end

      def run
        send_to_email if user.email
        send_push
        # send_sms
      end

      private

      def send_to_email
        UserMailer.unpaid_trips(user.email).deliver_now
      end

      def send_push
        message = 'У вас є несплачена поїздка. Перевірте, чи є кошти на вашій карті, або сплатіть другою картою'
        Jobs::Notification.perform_later(data[:user_id], message)
      end

      def send_sms
        sms_text = 'У вас є несплачена поїздка. Перевірте, чи є кошти на вашій карті, або сплатіть другою картою'
        Jobs::Sms.perform_later(user.phone_number, sms_text)
      end

      def user
        @user ||= User.find_by(id: data[:user_id])
      end
    end
  end
end
