module Jobs
  class UsersAnnounce < ActiveJob::Base
    queue_as :mailers

    def perform(batch_emails)
      batch_emails.each do |email|
        UserMailer.announce(email).deliver_now
      end
    end
  end
end
