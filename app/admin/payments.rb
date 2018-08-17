ActiveAdmin.register Payment do
  preserve_default_filters!
  remove_filter :trip
  filter :type, as: :select, collection: proc { Payment.distinct.pluck(:type) }
  filter :user, as: :select, collection: proc { User.joins(:trips).group(:id).all }
  filter :trip_created_at, as: :date_range

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :card, :user, :driver)
    end
  end

  show do
    attributes_table do
      Payment.column_names.each { |title| row title }
    end
    render 'custom_actions'
  end

  index do
    %w[id amount status type trip driver_id user card_pan response].each { |title| column title }
    column 'created_at' do |payment|
      payment.trip.created_at
    end
    actions
    div class: 'panel' do
      h4 "Total: #{Payment.search(params[:q]).result.sum(:amount)}"
    end
  end

  member_action :retry_payment, method: :post do
    payment = Payment.find(params[:id])
    card_id = payment.card_id || Card.find_by(user_id: payment.user_id)&.id
    Operations::Wayforpay::RetryPayment.new(payment.id, card_id).call
    notice = if payment.status == Constants::Payments::SUCCESS
               'Payment success'
             else
               'Something went wrong. Check response'
             end
    redirect_to admin_payment_path(payment), notice: notice
  end
end
