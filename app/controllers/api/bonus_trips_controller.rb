module Api
  class BonusTripsController < ApiApplicationController
    before_action :authorize!

    def index
      bonus_trips = BonusTrip.where(user_id: current_user.id)
      render json: { bonus_trips: Presenters::BonusTrips::Collection.new(bonus_trips) }.to_json, status: 200
    end
  end
end
