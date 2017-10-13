class AuthorizationsController < ApplicationController
  def create
    user = Events::Authorization.(sign_in_params)
    Presenters::Users::SinglePrivate.new(user).to_json
  end

  private

  def sign_in_params
    params.require(:user).permit(:phone_number, :password)
  end
end
