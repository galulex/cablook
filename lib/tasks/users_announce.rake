task users_announce: :environment do
  User.where.not(email: nil).pluck(:email).each do |email|
    UserMailer.announce(email).deliver_later
  end
end
