module Api
  class ApiApplicationController < ApplicationController
    rescue_from Constants::UnauthorizedError do |_errors|
      render json: { errors: ['User unauthorized'] }, status: 401
    end

    rescue_from Constants::NotFoundError do |_errors|
      render json: { errors: ['Not found'] }, status: 404
    end

    rescue_from Events::InvalidParamsError do |error|
      render json: { errors: JSON.parse(error.message) }, status: error.object[:status]
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { errors: error }, status: :unprocessable_entity
    end

    def current_user
      @current_user ||= Repositories::User.new(ROM.env).by_token(auth_token)
    end

    private

    def auth_token
      @auth_token ||= request.headers['Auth-Token']
    end

    def authorize!
      raise Constants::UnauthorizedError unless auth_token && current_user
    end
  end
end
