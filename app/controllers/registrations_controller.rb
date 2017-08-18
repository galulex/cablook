class RegistrationsController < ApplicationController
  def create
    user = Events::CreateUser.(user_attrs)
    render json: { user: user }
  end

  private

  def user_attrs
    {
      email: user_params[:email],
      encrypted_password: BCrypt::Password.create([:password])
    }
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
