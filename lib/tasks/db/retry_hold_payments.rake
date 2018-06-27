namespace :db do
  task :retry_hold_payments do
    Payment.includes(:trip).where(status: Constants::Payments::HOLD).find_each do |payment|
      Operations::Wayforpay.settle(payment.trip_id) unless payment.trip.created_at.today?
    end
  end
end
