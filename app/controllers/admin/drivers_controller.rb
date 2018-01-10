module Admin
  class DriversController < Admin::ApplicationController
    def index
      @users = driver_repository.all
    end

    def new; end

    def create
      driver_repository.create(driver_attrs)
      redirect_to admin_users_path
    end

    def update
      driver_repository.update(params[:id], driver_attrs)
      redirect_to admin_users_path
    end

    def destroy
      driver_repository.delete(params[:id])
      redirect_to admin_users_path
    end

    private

    def driver_repository
      @driver_repository ||= Repositories::Driver.new(ROM.env)
    end

    def driver_attrs
      {
        name: driver_params[:name],
        username: driver_params[:username],
        encrypted_password: BCrypt::Password.create(driver_params[:password])
      }.compact
    end

    def driver_params
      params.require(:driver).permit(:name, :username, :password)
    end
  end
end
