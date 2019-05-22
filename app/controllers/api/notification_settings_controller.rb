module Api
  class NotificationSettingsController < ApiApplicationController
    def update
      event = Events::NotificationSettings::Update.(user_id: current_user.id,
                                                    notification_settings: params['notification_settings'])
      event ? (render json: event) : (head :not_modified)
    end
  end
end
