module Jobs
  class SetFavAddress < ActiveJob::Base
    queue_as :default
    
    def perform
      return unless User.without_fav_address.any?
      
      User.without_fav_address.find_each do |u| 
        u.favorite_addresses.create(name: '⭐', location: u.destination.join(','), address: u.destination_address)
      end
    end
  end
end