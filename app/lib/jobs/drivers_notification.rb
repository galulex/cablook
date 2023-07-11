module Jobs
  class DriversNotification < ActiveJob::Base
    def perform(trip, message = '')
      I18n.locale = trip.user.locale
      send_fcm_notifications(trip, message)
    end

    private

    def send_fcm_notifications(trip, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      fcm.send(Driver.where.not(device: nil).pluck(:device), options(trip, message))
    end

    def options(trip, message)
      message = message == 'clear' ? message : "📍 #{trip.departure_address}\n🏁 #{trip.destination_address}"

      options = {
        data: {
          title: "💰 #{trip.cost} грн - 🚕 #{trip.distance / 1000} км",
          body: message,
          icon: '/icon_128x128.png',
          tag: trip.id.to_s
        }
      }
      options[:data][:trip][:action] = 'remove_notifications' if message == 'clear'

      options
    end
  end
end
