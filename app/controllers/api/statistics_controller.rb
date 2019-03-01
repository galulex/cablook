module Api
  class StatisticsController < ApiApplicationController
    def show
      render json: { statistics: statistics_in_period }, status: 200
    end

    private

    def statistics_in_period
      period == 'all_time' ? statistics.first : statistics.send(period).first
    end

    def statistics
      current_user.trips.statistics
    end

    def period
      params[:period]
    end
  end
end
