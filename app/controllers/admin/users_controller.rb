module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = user_repository.all
    end

    def new; end

    def create
      user_repository.create(user_params)
      redirect_to admin_users_path
    end

    def update
      user_repository.update(params[:id], user_params)
      redirect_to admin_users_path
    end

    def destroy
      user_repository.delete(params[:id])
      redirect_to admin_users_path
    end

    private

    def user_repository
      @user_repository ||= Repositories::User.new(ROM.env)
    end

    def user_params
      params.require(:user).permit(:email, :phone_number).to_h.symbolize_keys
    end
  end
end
