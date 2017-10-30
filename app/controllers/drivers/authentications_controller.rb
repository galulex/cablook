class Drivers::AuthenticationsController < ApplicationController
  def create
    driver = Events::Drivers::Authentication.(sign_in_params)
    Presenters::Drivers::SinglePrivate.new(driver).to_json
  end

  private

  def sign_in_params
    params.require(:driver).permit(:username, :password)
  end
end
