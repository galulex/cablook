module Api
  class ReferralsController < ApiApplicationController
    before_action :authorize!

    def index
      parent_bonus = bonus_repository.by_friend(current_user.id)
      bonus_trips = bonus_repository.by_user(current_user.id)
      render(
        json: {
          parent_bonus: Presenters::BonusTrips::Collection.new(parent_bonus),
          bonus_trips: Presenters::BonusTrips::Collection.new(bonus_trips)
        }.to_json,
        status: 200
      )
    end

    def create
      Events::Users::AddReferral.(referral_code: referral_code, referral_id: current_user.id)
      render json: {}, status: 200
    end

    private

    def referral_code
      params.require(:referral_code)
    end

    def bonus_repository
      @bonus_repository ||= Repositories::BonusTrip.new(ROM.env)
    end
  end
end
