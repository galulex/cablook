module Api
  class UsersController < ApiApplicationController
    before_action :user, :prevent_page_caching

    def show
      response = user.as_json(only: %i(id email phone_number locale), include: %i(favorite_addresses bonus_trips parent_bonus), methods: %i(enabled_notifications current_trip))
      response['cards'] = Card.user_cards(user.id).as_json
      render json: response, status: 200
    end

    def update
      update_user
      render json: { user: user.to_json }, status: 200
    end

    private

    def user
      @user ||= User.fetch_user(auth_token)[0]
      @user ? @user : (raise Constants::NotFoundError)
    end

    def update_user
      user.update(user_params)
    end

    def prevent_page_caching
      response.headers['Cache-Control'] = 'no-cache, no-store'
      response.headers['Pragma']        = 'no-cache'
      response.headers['Expires']       = '0'
    end

    def user_params
      params.require(:user).permit(:locale)
    end
  end
end
