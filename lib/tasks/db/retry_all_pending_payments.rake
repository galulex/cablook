namespace :db do
  task :retry_all_pending_payments => :environment  do
    Operations::RetryAllPendingPayments.call
  end
end
