class FeedbacksController < ApplicationController
  def create
    feedback = Events::CreateFeedback.(feedback_params)
    render json: { feedback: feedback }
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rate, :description).merge(
      trip_id: params[:trip_id].to_i,
      user_id: current_user.id
    )
  end
end
