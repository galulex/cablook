module Events
  module Users
    class Notify < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        send_to_email if user.email
        send_push
      end

      private

      def send_to_email
        UserMailer.unpaid_trips(user.email).deliver_now
      end

      def send_push
        message = 'У вас є несплачена поїздка. Перевірте, чи є кошти на вашій карті, або сплатіть іншою картою'
        Jobs::Notification.perform_later(trip, message)
      end

      def trip
        @trip ||= Trip.find_by(id: data[:trip_id])
      end

      def user
        @user ||= trip.user
      end
    end
  end
end
