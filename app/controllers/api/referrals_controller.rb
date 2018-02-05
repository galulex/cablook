module Api
  class ReferralsController < ApiApplicationController
    before_action :authorize!

    def create
      Events::AddReferrer.(referral_code: referral_code, referral_id: current_user.id)
      render json: {}, status: 200
    end

    private

    def referral_code
      params.require(:referral_code)
    end
  end
end
