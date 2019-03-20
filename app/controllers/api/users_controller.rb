module Api
  class UsersController < ApiApplicationController
    before_action :authorize!

    def show
      render json: current_user.to_json(only: %i(email phone_number), include: %i(cards bonus_trips favorite_addresses)), status: 200
    end

  end
end
