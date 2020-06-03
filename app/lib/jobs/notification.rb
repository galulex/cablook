module Jobs
  class Notification < ActiveJob::Base
    def perform(trip, message)
      I18n.locale = trip.user.locale
      send_push_to_android_devices(trip, message)
      send_push_to_ios_devices(trip, message)
    end

    private

    def send_push_to_android_devices(trip, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      registration_ids = trip.user.devices.fcm.pluck(:token)
      options = {
        mutable_content: true,
        content_available: true,
        badge: 9,
        notification: {
          title: 'CabLook',
          body: message,
          sound: 'default'
        },
        data: {
          title: 'CabLook',
          body: message,
          icon: '/icon_128x128.png',
          tag: 'renotify',
          renotify: true,
          trip: {
            id: trip.id.to_s,
            user_token: trip.user.auth_token
          }
        },
        priority: 'high'
      }
      case trip.status
      when Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]
        options[:data][:trip][:loading] = true
      when Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        options[:data][:actions] = {
          actions: [
            {
              action: 'retry',
              title: I18n.t('notification.actions.retry')
            },
            {
              action: 'cancel',
              title: I18n.t('notification.actions.cancel')
            }
          ]
        }
        options[:data][:trip][:action] = message == 'clear' ? 'remove_notifications' : 'retry'
        options[:notification][:click_action] = 'cablook.retry'
      when Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]
        options[:data][:trip][:action] = 'remove_notifications'
      when Constants::Trip::STATUS_CODES[Constants::Trip::DRIVING]
        options[:data][:trip][:action] = 'driving'
      when Constants::Trip::STATUS_CODES[Constants::Trip::WAITING_CLIENT]
        options[:data][:actions] = {
          actions: [
            {
              action: 'coming',
              title: I18n.t('notification.actions.coming')
            }
          ]
        }
        options[:data][:trip][:action] = 'coming'
      when Constants::Trip::STATUS_CODES[Constants::Trip::ON_THE_WAY]
        options[:data][:actions] = {
          actions: [
            {
              action: 'reply',
              title: I18n.t('notification.actions.reply')
            }
          ]
        }
        options[:data][:trip][:action] = 'reply'
        options[:notification][:click_action] = 'cablook.reply'
      else
      end
      fcm.send(registration_ids, options)
    end

    def send_push_to_ios_devices(trip, message)
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
