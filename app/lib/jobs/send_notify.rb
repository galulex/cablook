module Jobs
  class SendNotify < ActiveJob::Base
    queue_as :push_notifications

    def perform(options)
      users = options[:user_id] ? User.where(id: options[:user_id]) : User.all
      users.each { |user| send_fcm_notification(user, options[user.locale.to_sym]) }
    end

    private

    def send_fcm_notification(user, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      devices = user.devices
      registration_ids = devices.fcm.pluck(:token)
      ios_fcm_ids = devices.ios_fcm.pluck(:token)
      fcm.send(ios_fcm_ids, fcm_data_options(message)) unless ios_fcm_ids.empty?
      fcm.send(registration_ids, fcm_data_options(message)) unless registration_ids.empty?
    end

    def fcm_data_options(message)
      {
        notification: {
          title: 'CabLook',
          body: message,
          sound: 'default'
        }
      }
    end
  end
end
