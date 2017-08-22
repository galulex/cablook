class ApplicationController < ActionController::API
  rescue_from Events::InvalidParamsError do |errors|
    render json: { errors: JSON.parse(errors.message) }, status: 400
  end

  def current_user
    @current_user ||= Users::Repository.new.by_token!(params[:auth_token])
  rescue StandardError
    render json: { errors: ['User unauthorized'] }, status: 401
  end
end
