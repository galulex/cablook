module Api
  class UsersController < ApiApplicationController

    def show
      user = User.fetch_user(auth_token)[0]
      raise Constants::NotFoundError if user.nil?
      
      user_id = user.id
      user = user.as_json(only: %i(id email phone), include: %i(favorite_addresses bonus_trips parent_bonus))
      user['cards'] = Card.user_cards(user_id).as_json
      render json: user, status: 200
    end
  end
end
