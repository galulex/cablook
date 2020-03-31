module Api
  class NotificationsController < ApiApplicationController
    before_action :authorize!

    def new
      message = params[:message] ? params[:message] : nil
      Events::Drivers::Notify.(message: message, trip_id: params[:trip_id].to_i, message_type: params[:message_type])
      render json: { message: message }.to_json, status: 200
    end
  end
end
