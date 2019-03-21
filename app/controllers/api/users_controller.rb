module Api
  class UsersController < ApiApplicationController

    def show
      user = User.eager_load(:cards, :favorite_addresses, :bonus_trips)
             .where(auth_token: auth_token)[0]
             .as_json(only: %i(email phone), include: [cards: {except: :token}, favorite_addresses: {}, bonus_trips: {}])
      
      user ? (render json: user, status: 200) : (render json: { errors: ['Not found'] }, status: 404)
    end

  end
end
