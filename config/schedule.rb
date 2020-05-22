every :sunday, at: '3:00am' do
  rake 'db:retry_all_pending_payments'
end

every :day, at: '0:05am' do
  rake 'schedule_daily_trip_suggestions'
end