module Api
  class FeedbacksController < ApiApplicationController
    before_action :authorize!

    def create
      feedback = Events::Feedbacks::Create.(feedback_params)
      render json: Presenters::Feedbacks::Single.new(feedback).to_json, status: 201
    end

    private

    def feedback_params
      params.require(:feedback).permit(:rate, :description).merge(
        trip_id: trip_id,
        user_id: current_user.id
      )
    end

    def trip_id
      params[:trip_id].to_i
    end
  end
end
