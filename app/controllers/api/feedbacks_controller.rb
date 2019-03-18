module Api
  class FeedbacksController < ApiApplicationController
    before_action :authorize!

    def create
      feedback = Events::Feedbacks::Create.(feedback_params)
      render json: Presenters::Feedbacks::Single.new(feedback).to_json, status: 201
    end

    private

    def feedback_params
      params.fetch(:feedback, {}).permit(:rate, :description).reverse_merge(
        rate: 5,
        trip_id: trip_id,
        tip: tip,
        user_id: current_user.id
      )
    end

    def trip_id
      params[:trip_id].to_i
    end

    def tip
      params[:tip].to_i
    end
  end
end
