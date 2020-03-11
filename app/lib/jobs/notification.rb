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
      case trip&.status
      when Constants::Trip::PENDING
        options = {
          notification: {
            title: 'CabLook',
            body: message,
            icon: '/icon_128x128.png',
            tag: trip.id.to_s
          },
          data: {
            trip_id: trip.id.to_s,
            actions: {
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
          },
          collapse_key: user_id.to_s
        }
      when Constants::Trip::DECLINED
        options = {
          notification: {
            title: 'CabLook',
            body: message,
            icon: '/icon_128x128.png',
            tag: trip.id.to_s
          },
          data: {
            trip_id: trip.id.to_s,
            actions: {
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
          },
          collapse_key: user_id.to_s
        }
      else
        options = {
          notification: {
            title: 'CabLook',
            body: message,
            icon: '/icon_128x128.png',
            tag: trip.id.to_s
          },
          data: {
            actions: {
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
          },
          collapse_key: '1'
        }
      end
      response = fcm.send(registration_ids, options)
      p response
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
