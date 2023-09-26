task users_announce: :environment do
  Jobs::UsersAnnounce.perform_later
end
