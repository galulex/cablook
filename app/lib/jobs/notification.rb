module Jobs
  class Notification < ActiveJob::Base
    def perform(trip, message)
      I18n.locale = trip.user.locale
      send_fcm_notifications(trip, message)
      send_one_signal_notifications(trip, message)
    end

    private

    def send_fcm_notifications(trip, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      devices = trip.user.devices
      registration_ids = devices.fcm.pluck(:token)
      ios_fcm_ids = devices.ios_fcm.pluck(:token)
      options = set_fcm_options(trip, message)
      ios_fcm_options = set_fcm_ios_options(trip.status, message)
      fcm.send(ios_fcm_ids, ios_fcm_options)
      fcm.send(registration_ids, options)
    end

    def send_one_signal_notifications(trip, message)
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

    def fcm_options(trip, message)
      {
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
        }
      }
    end

    def fcm_ios_options(message)
      {
        mutable_content: true,
        content_available: true,
        badge: 9,
        notification: {
          title: 'CabLook',
          body: message,
          sound: 'default'
        },
        priority: 'high'
      }
    end

    def set_fcm_options(trip, message)
      options = fcm_options(trip, message)
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
      when Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED], Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED_BY_DRIVER]
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
      end
      options
    end

    def set_fcm_ios_options(status, message)
      options = fcm_ios_options(message)
      case status
      when Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        options[:notification][:click_action] = 'cablook.retry'
      when Constants::Trip::STATUS_CODES[Constants::Trip::ON_THE_WAY]
        options[:notification][:click_action] = 'cablook.reply'
      end
      options
    end
  end
end
