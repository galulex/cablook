ActiveAdmin.register_page 'Notifications' do
  page_action :notify, method: :post do
    Jobs::SendNotify.perform_later(notification_params)
  end

  controller do
    def notification_params
      params.permit(:en, :ru, :ua, :user_id)
    end
  end

  content do
    render 'index'
  end
end
