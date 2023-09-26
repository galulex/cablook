module Jobs
  class UsersAnnounce < ActiveJob::Base
    queue_as :mailers

    def perform(email)
        UserMailer.announce(email).deliver_later
    end
  end
end
