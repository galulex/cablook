module Jobs
  class SendNotify < ActiveJob::Base
    queue_as :notifications

    def perform(options)
      users = options[:user_id] ? User.where(id: options[:user_id]) : User.all
      users.each { |user| send_fcm_notification(user, options[user.locale]) }
    end

    private

    def send_fcm_notification(user, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      fcm.send(user.devices.fcm.pluck(:token), fcm_data_options(message))
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
