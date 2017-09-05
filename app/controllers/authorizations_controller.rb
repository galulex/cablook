class AuthorizationsController < ApplicationController
  def create
    user = Events::Authorization.(sign_in_params)
    render json: { user: user }
  end

  private

  def sign_in_params
    params.require(:user).permit(:phone_number, :password)
  end
end
