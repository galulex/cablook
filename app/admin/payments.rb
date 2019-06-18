ActiveAdmin.register Payment do
  preserve_default_filters!
  remove_filter :trip
  filter :type, as: :select, collection: proc { Payment.distinct.pluck(:type) }
  filter :user, as: :select, collection: proc { User.joins(:trips).group(:id).all }
  filter :trip_car_id, as: :select, collection: proc { Car.all.group(:id) }
  filter :trip_created_at, as: :date_range

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :card, :user, :driver)
    end

    def retry_queue
      Sidekiq::Queue.new('retry_payments')
    end

    def retry_all(with_sms)
      if retry_queue.size.zero?
        Payment.where(status: Constants::Payments::PENDING).joins(:trip).where(trips: { status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED] }).find_each do |payment|
          begin
            card = payment.card || payment.user.cards.last
            if card
              Jobs::PaymentRetry.perform_later(payment.id, payment.card_id, with_sms)
            end
          end
        end
        redirect_to collection_path, notice: 'Retry successfully'
      else
        redirect_to collection_path, alert: 'Currently payment retry is not available. Please try again later'
      end
    end
  end

  index do
    %w[id amount status type trip user card_pan response].each { |title| column title }
    column 'driver_id' do |payment|
      payment&.trip&.driver_id
    end
    column 'car_id' do |payment|
      payment&.trip&.car_id
    end
    column 'created_at' do |payment|
      payment&.trip&.created_at
    end
    actions
    div class: 'panel' do
      h4 "Total: #{Payment.search(params[:q]).result.sum(:amount)}"
    end
  end

  show do
    attributes_table do
      Payment.column_names.each { |title| row title }
    end
    render 'custom_actions'
  end

  form do |f|
    semantic_errors
    inputs do
      f.input :card, label: 'Card', as: :select, collection: Card.where(user_id: payment.user_id).map { |c| [c.pan, c.id] }
      %w[amount status order_reference response].each { |title| input title }
    end
    actions
  end

  action_item(:retry) { link_to 'Retry All', retry_all_without_sms_admin_payments_path, method: :post }
  action_item(:retry) { link_to 'Retry All With Sms', retry_all_with_sms_admin_payments_path, method: :post }

  collection_action :retry_all_without_sms, method: :post do
    retry_all(false)
  end

  collection_action :retry_all_with_sms, method: :post do
    retry_all(true)
  end

  member_action :refund_payment, method: :post do
    payment = Payment.find(params[:id])
    Operations::Wayforpay::Refund.new(payment.id).call
    notice = if payment.reload.status == Constants::Payments::REFUND
               'Refund success'
             else
               'Something went wrong. Check response'
             end
    redirect_to admin_payment_path(payment), notice: notice
  end

  member_action :retry_payment, method: :post do
    payment = Payment.find(params[:id])
    card_id = payment.card_id || Card.find_by(user_id: payment.user_id)&.id
    Operations::Wayforpay::RetryPayment.new(payment.id, card_id).call
    notice = if payment.reload.status == Constants::Payments::SUCCESS
               'Payment success'
             else
               'Something went wrong. Check response'
             end
    redirect_to admin_payment_path(payment), notice: notice
  end
end
