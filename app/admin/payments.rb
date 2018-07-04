ActiveAdmin.register Payment do
  remove_filter :trip

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :card, :user)
    end
  end

  show do
    attributes_table do
      Payment.column_names.each { |title| row title }
    end
    render 'custom_actions'
  end

  index do
    %w[id amount status type trip user card_pan response].each { |title| column title }
    actions
  end

  member_action :retry_payment, method: :post do
    payment = Payment.find(params[:id])
    card_id = payment.card_id || Card.find_by(user_id: payment.user_id)&.id
    Operations::Wayforpay::RetryPayment.new(payment.id, payment.card_id).call
    notice = if payment.status == Constants::Payments::SUCCESS
               'Payment success'
             else
               'Something went wrong. Check response'
             end
    redirect_to admin_payment_path(payment), notice: notice
  end
end
