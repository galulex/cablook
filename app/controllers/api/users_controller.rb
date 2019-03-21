module Api
  class UsersController < ApiApplicationController

    def show
      user = User.eager_load(:cards, :favorite_addresses, :bonus_trips)
             .where(auth_token: auth_token)[0]
             .as_json(only: %i(email phone), include: [cards: {except: :token}, favorite_addresses: {}, bonus_trips: {}], status: 200)
      render json: user
    end

  end
end
