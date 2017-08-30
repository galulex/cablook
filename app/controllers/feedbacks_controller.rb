class FeedbacksController < ApplicationController
  before_action :authorize!

  def create
    feedback = Events::CreateFeedback.(feedback_params)
    render json: { feedback: feedback }
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
