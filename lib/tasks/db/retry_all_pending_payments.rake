namespace :db do
  task :retry_all_pending_payments do
    Operations::RetryAllPendingPayments.call
  end
end
