module Jobs
  class Notification < ActiveJob::Base
    def perform(user_id, message)
      send_push_to_android_devices(user_id, message)
      send_push_to_ios_devices(user_id, message)
    end

    private

    def send_push_to_android_devices(user_id, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      registration_ids = Device.where(user_id: user_id).where.not(platform: Constants::Device::IOS).pluck(:token)
      options = {
        notification: {
          title: 'CabLook',
          body: message,
          icon: '/icon_128x128.png'
        }
      }
      fcm.send(registration_ids, options)
    end

    def send_push_to_ios_devices(user_id, message)
      registration_ids = Device.where(user_id: user_id).where(platform: Constants::Device::IOS).pluck(:token)
      params = {
        app_id: ENV['ONE_SIGNAL_APP_ID'],
        contents: { en: message },
        include_player_ids: registration_ids
      }
      OneSignal::Notification.create(params: params)
    end
  end
end
