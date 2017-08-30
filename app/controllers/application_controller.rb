class ApplicationController < ActionController::API
  UnauthorizedError = Class.new(StandardError)

  rescue_from UnauthorizedError do |errors|
    render json: { errors: ['User unauthorized'] }, status: 401
  end

  rescue_from Events::InvalidParamsError do |errors|
    render json: { errors: JSON.parse(errors.message) }, status: 400
  end

  def current_user
    @current_user ||= Repositories::User.new.by_token(params[:auth_token])
  end

  private

  def authorize!
    raise UnauthorizedError unless params[:auth_token] && current_user
  end
end
