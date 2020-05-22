module Jobs
  class SendTripSuggestionJob < ActiveJob::Base
    def perform(trip_suggestion)
      I18n.locale = trip.user.locale
      send_push_to_android_devices(trip_suggestion)
      send_push_to_ios_devices(trip_suggestion)
    end

    private

    def send_push_to_android_devices(trip_suggestion)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      registration_ids = trip.user.devices.fcm.pluck(:token)
      message = I18n.t('notification.trip_suggestion', address: trip_suggestion.destination_address)
      options = {
        notification: {
          body: message,
          title: 'CabLook',
          sound: 'default'
        },
        apns: {
          payload: {
            aps: {
              sound: 'default'
            }
          }
        },
        priority: 'high',
        data: {
          title: 'CabLook',
          body: message,
          icon: '/icon_128x128.png',
          tag: 'renotify',
          renotify: true,
          actions: {
            actions: [
              {
                action: 'accept',
                title: I18n.t('notification.actions.accept_suggestions')
              },
              {
                action: 'decline',
                title: I18n.t('notification.actions.decline')
              },
            ]
          }

          # trip: {
          #   id: trip.id.to_s,
          #   user_token: trip.user.auth_token
          # }
        }
      }
      fcm.send(registration_ids, options)
    end

    def send_push_to_ios_devices(trip_suggestion)
      registration_ids = trip.user.devices.one_signal.pluck(:token)
      return if registration_ids.empty?
      params = {
        app_id: ENV['ONE_SIGNAL_APP_ID'],
        contents: { en: message },
        include_player_ids: registration_ids,
        collapse_id: trip.user_id.to_s
      }
      OneSignal::Notification.create(params: params)
    end
  end
end