module Jobs
  class Notification < ActiveJob::Base
    def perform(user_id, message)
      fcm = FCM.new(ENV['FCM_SERVER_KEY'])
      registration_ids = Device.where(user_id: user_id).pluck(:token)
      options = { 'notification': { 'title': 'CabLook', 'body': message } }
      fcm.send(registration_ids, options)
    end
  end
end
