module Api
  class StatisticsController < ApiApplicationController
    before_action :authorize!

    def show
      render json: { statistics: statistics }, status: 200
    end

    private

    def statistics
      current_user.trips.statistics.send(params[:period]).first
    end
  end
end
