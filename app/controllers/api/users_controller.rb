module Api
  class UsersController < ApiApplicationController
    before_action :user

    def show
      response = user.as_json(only: %i(id email phone), include: %i(favorite_addresses bonus_trips parent_bonus))
      response['cards'] = Card.user_cards(user.id).as_json
      render json: response, status: 200
    end

    private

    def user
      @user ||= User.fetch_user(auth_token)[0]
      @user ? @user : (raise Constants::NotFoundError)
    end
  end
end
