module DriversApp
  class ApplicationController < ActionController::API
    UnauthorizedError = Class.new(StandardError)

    rescue_from UnauthorizedError do |_errors|
      render json: { errors: ['User unauthorized'] }, status: 401
    end

    rescue_from Events::InvalidParamsError do |errors|
      render json: { errors: JSON.parse(errors.message) }, status: 400
    end

    def current_driver
      @current_driver ||= Repositories::Driver.new(ROM.env).by_token(auth_token)
    end

    private

    def auth_token
      @auth_token ||= request.headers['Auth-Token']
    end

    def authorize!
      raise UnauthorizedError unless auth_token && current_driver
    end
  end
end
