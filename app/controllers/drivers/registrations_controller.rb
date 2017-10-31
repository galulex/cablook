class Drivers::RegistrationsController < ApplicationController
  def create
    driver = Events::CreateDriver.(driver_attrs)
    render json: Presenters::Drivers::SinglePrivate.new(driver).to_json, status: 201
  end

  private

  def driver_attrs
    {
      name: driver_params[:name],
      username: driver_params[:username],
      encrypted_password: BCrypt::Password.create(driver_params[:password])
    }
  end

  def driver_params
    params.require(:driver).permit(:name, :username, :password)
  end
end
