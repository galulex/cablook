module Jobs
  class PaymentSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, payment_type, amount = nil)
      Operations::Wayforpay::DoPayment.new(trip_id, payment_type, amount).call if settings.wayforpay?
      Operations::Fondy::DoPayment.new(trip_id, payment_type, amount).call if settings.fondy?
    end

    private

    def settings
      @settings ||= Settings.get
    end
  end
end
