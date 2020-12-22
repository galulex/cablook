extend ActionView::Helpers

namespace :db do
  task update_fav_address: :environment do 
    
    def users_without_fav_address(type)
      User.left_joins(:favorite_addresses)
      .joins(:trips)
      .where(favorite_addresses: { id: nil }, trips: { status: 'finished' })
      .where.not(trips: { waypoints: [], stops: [] })
      .group("users.id, trips.waypoints[#{type}], trips.stops[#{type}]")
      .select("users.id, trips.waypoints[#{type}], trips.stops[#{type}]")
      .having('count(*) >= 5')
    end
    
    favorite_address = users_without_fav_address(1) + users_without_fav_address(2)
    
    addresses_count = favorite_address.pluck(:id).length
    users_count = favorite_address.pluck(:id).uniq.length

    favorite_address.each do |user|
      user.favorite_addresses.create(name: '⭐', location: user.waypoints, address: user.stops)
    end 
    
    Logger.new(STDOUT).info("#{pluralize(addresses_count, 'address', plural: 'addresses')} have been added to #{pluralize(users_count, 'user', plural: 'users')}")

  end
end
