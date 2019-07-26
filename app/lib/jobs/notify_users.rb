module Jobs
  class NotifyUsers < ActiveJob::Base
    def perform(users_ids)
      users_ids.each do |user_id|
        Events::Users::Notify.(user_id: user_id)
      end
    end
  end
end

