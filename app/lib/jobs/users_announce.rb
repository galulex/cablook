module Jobs
  class UsersAnnounce < ActiveJob::Base
    queue_as :mailers

    def perform
      User.where.not(email: nil).where('trips_count > ?', 10).pluck(:email).each_slice(90) do |batch_emails|
        batch_emails.each do |email|
          UserMailer.announce(email).deliver_now
        end

        sleep 65.minutes
      end
    end
  end
end
