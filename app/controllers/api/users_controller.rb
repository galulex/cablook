module Api
  class UsersController < ApiApplicationController

    def show
      user = User.fetch_user(auth_token)
      user.empty? ? (render json: { errors: ['Not found'] }, status: 404) : (render json: user, status: 200)
    end

  end
end
