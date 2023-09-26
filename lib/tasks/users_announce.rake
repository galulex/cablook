task :users_announce, [:limit, :trips_count, :condition] => :environment do |t, args|
  limit = args[:limit].to_i || 0
  trips_count = args[:trips_count].to_i || 0
  condition = args[:condition] || '='
  emails = User.where.not(email: nil).where("trips_count #{condition} ?", trips_count).limit(limit).pluck(:email)
  emails.each_with_index.map do |email, index|
    Jobs::UsersAnnounce.set(wait: index.minutes).perform_later(email)
  end
end
