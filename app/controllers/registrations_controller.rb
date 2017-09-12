class RegistrationsController < ApplicationController
  def create
    user = Events::CreateUser.(user_attrs)
    render json: { user: user }
  end

  private

  def user_attrs
    {
      phone_number: user_params[:phone_number],
      email: user_params[:email],
      encrypted_password: BCrypt::Password.create(user_params[:password])
    }
  end

  def user_params
    params.require(:user).permit(:phone_number, :email, :password)
  end
end
