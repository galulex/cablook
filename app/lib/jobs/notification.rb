module Jobs
  class Notification < ActiveJob::Base
    def perform(user_id, message, trip=nil)
      send_push_to_android_devices(user_id, message, trip)
      send_push_to_ios_devices(user_id, message, trip)
    end

    private

    def send_push_to_android_devices(user_id, message, trip)
      fcm = FCM.new('AAAAe2eP_kY:APA91bE0w-nciamie2P8nKia0VzPLZHfgMZD8pgTBS8qDSgxQGcNAWeuZrvn2CjDonM-IGywkX0B6eLcVrke5UL2EHg-OibvyqXW-Vuag42kCZt6b71G3IAvX1AvXlE9OLrr4J76aZXS')
      registration_ids = Device.where(user_id: user_id).where.not(platform: Constants::Device::IOS).pluck(:token)
      options = {
        notification: {
          title: 'CabLook',
          body: message,
          icon: '/icon_128x128.png',
          tag: 'renotify',
          renotify: true
        },
        data: {
          trip: {
            trip_id: trip.id.to_s,
            auth_token: trip.user.auth_token
          }
        }
      }
      case trip&.status
      when Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]
        options[:data][:trip][:loading] = true
      when Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        options[:data][:actions] = {
          actions: [
            {
              action: 'retry',
              title: 'Retry'
            },
            {
              action: 'cancel',
              title: 'Cancel'
            }
          ]
        }
      when Constants::Trip::STATUS_CODES[Constants::Trip::WAITING_CLIENT]
        options[:data] = {
          actions: {
            actions: [
              {
                action: 'coming',
                title: 'Coming'
              }
            ]
          },
          trip: options[:data][:trip],
          message: 'Уже йду'
        }
      when Constants::Trip::STATUS_CODES[Constants::Trip::ON_THE_WAY]
        options[:data][:actions] = {
          actions: {
            actions: [
              {
                action: 'reply',
                title: 'Reply'
              }
            ]
          }
        }
      else
        return
      end
      fcm.send(registration_ids, options)
    end

    def send_push_to_ios_devices(user_id, message, trip)
      registration_ids = Device.where(user_id: user_id).where(platform: Constants::Device::IOS).pluck(:token)
      return if registration_ids.empty?
      params = {
        app_id: ENV['ONE_SIGNAL_APP_ID'],
        contents: { en: message },
        include_player_ids: registration_ids,
        collapse_id: user_id.to_s
      }
      OneSignal::Notification.create(params: params)
    end
  end
end
