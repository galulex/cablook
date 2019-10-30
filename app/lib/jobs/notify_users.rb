module Jobs
  class NotifyUsers < ActiveJob::Base
    def perform(users_ids)
      users_ids.each_slice(90) do |ids_group|
        ids_group.each do |user_id|
          Events::Users::Notify.(user_id: user_id)
        end
        sleep(1.hours)
      end
      Redis.current.set("button_state", false)
    end
  end
end
