namespace :db do
  task :update_total_and_idle => :environment do 
    Trip.includes(:payments).each do |trip|
      idle = trip.idle_payment&.amount.to_i
      trip.update(total: trip.cost + idle, idle: idle)
    end
  end
end
