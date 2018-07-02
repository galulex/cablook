namespace :db do
  task :retry_hold_payments do
    Payments::Trip.includes(:trip).where(status: Constants::Payments::HOLD).find_each do |payment|
      if payment.finished? && !payment.trip.created_at.today?
        Operations::Wayforpay.settle(payment.trip_id)
      end
    end
  end
end
