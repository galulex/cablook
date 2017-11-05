class AuthorizationsController < ApplicationController
  def create
    user = Events::Authorization.(sign_in_params)
    render json: Presenters::Users::SinglePrivate.new(user).to_json, status: 201
  end

  private

  def sign_in_params
    params.require(:user).permit(:phone_number, :password)
  end
end
