module Api
  class PaymentsController < ApiApplicationController
    before_action :authorize!

    def index
      payments = Payments::Trip.where(user_id: current_user.id)
      render json: payments.to_json
    end

    def retry_pendings
      Operations::RetryUserPendingPayments.new(current_user.id, card_id).call
      render json: pending_payments.to_json, status: 200
    end

    def pending
      render json: pending_payments.to_json, status: 200
    end

    private

    def card_id
      params.require(:card_id)
    end

    def pending_payments
      @pending_payments ||= Payment.where(status: Constants::Payments::PENDING, user_id: current_user.id)
                                   .joins(:trip)
                                   .where(trips: { status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED] })
    end
  end
end
