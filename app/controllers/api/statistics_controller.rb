module Api
  class StatisticsController < ApiApplicationController
    def show
      render json: { statistics: statistics }, status: 200
    end

    private

    def statistics
      current_user.trips.statistics.first
    end
  end
end
