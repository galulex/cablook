every :sunday, at: '3:00am' do
  rake 'db:retry_all_pending_payments'
end

every :month, at: '12:00am' do
  rake 'db:update_fav_address'
end
