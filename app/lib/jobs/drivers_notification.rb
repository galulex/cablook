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
      fcm.send(Driver.where.not(device: nil).pluck(:device).compact, options(trip, message))
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
        apns: {
          headers: {
            'apns-priority' => '10',
            'apns-expiration' => (Time.now + MESSAGE_LIFETIME).to_i.to_s
          },
          payload: {
            aps: {
              sound: 'default'
            }
          }
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
  end
end
