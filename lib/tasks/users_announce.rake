task users_announce: :environment do
  emails = User.where.not(email: nil).where('trips_count > ?', 10).limit(450).pluck(:email)
  emails.each_slice(90).each_with_index.map do |emails_array, index|
    Jobs::UsersAnnounce.set(wait: (6 * index).hours).perform_later(emails_array)
  end
end
