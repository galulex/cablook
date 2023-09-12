module Jobs
  class DriversNotification < ActiveJob::Base
    MESSAGE_LIFETIME = 1.minute

    def perform(trip, message = '')
      I18n.locale = trip.user.locale
      send_fcm_notifications(trip, message)
    end

    private

    def send_fcm_notifications(trip, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      fcm.send(Driver.fcm_tokens.ios_devices, ios_fcm_options(trip)) unless message == 'clear'
      fcm.send(Driver.fcm_tokens.not_ios_devices, options(trip, message))
    end

    def options(trip, message)
      message = message == 'clear' ? message : "📍 #{trip.departure_address}\n🏁 #{trip.destination_address}"

      options = {
        collapse_key: trip.id.to_s,
        data: {
          title: "💰 #{trip.cost} грн - 🚕 #{trip.distance / 1000} км",
          body: message,
          icon: '/icon_128x128.png',
          tag: trip.id.to_s
        },
        android: {
          priority: 'high',
          ttl: MESSAGE_LIFETIME.to_i.to_s
        },
        webpush: {
          headers: {
            Urgency: 'high',
            TTL: MESSAGE_LIFETIME.to_i.to_s
          }
        }
      }
      options[:data][:action] = 'remove_notifications' if message == 'clear'

      options
    end

    def ios_fcm_options(trip)
      {
        notification: {
          title: "💰 #{trip.cost} грн - 🚕 #{trip.distance / 1000} км",
          body: "📍 #{trip.departure_address}\n🏁 #{trip.destination_address}",
          sound: "default"
        }
      }
    end
  end
end
