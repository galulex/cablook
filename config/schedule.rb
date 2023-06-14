set :output, "#{path}/log/cron.log"
set :environment, ENV['RAILS_ENV'] || 'development'
env :PATH, ENV['PATH']

every :sunday, at: '3:00am' do
  rake 'db:retry_all_pending_payments'
end

every :month, at: '12:00am' do
  rake 'db:update_fav_address'
end

every 1.minute do
    rake 'broadcast_location'
end
