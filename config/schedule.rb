every :day, at: '3:00am', roles: [:db] do
  rake 'db:retry_all_pending_payments'
end
