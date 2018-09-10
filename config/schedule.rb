every :sunday, at: '3:00am' do
  rake 'db:retry_all_pending_payments'
end
