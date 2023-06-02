module Api
  class ApiApplicationController < ApplicationController
    rescue_from Constants::UnauthorizedError do |_errors|
      render json: { errors: ['User unauthorized'] }, status: 401
    end

    rescue_from Constants::NotFoundError, ActiveRecord::RecordNotFound do |_errors|
      render json: { errors: ['Not found'] }, status: 404
    end

    rescue_from Events::InvalidParamsError do |error|
      render json: { errors: JSON.parse(error.message) }, status: error.object[:status]
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { errors: error }, status: :unprocessable_entity
    end

    def current_user
      @current_user ||= User.find_by(auth_token: auth_token)
    end

    def current_driver
      @current_driver ||= Driver.find_by(auth_token: auth_token)
    end

    def info_for_paper_trail
      { whodunnit_type: current_user.class.name }
    end

    private

    def settings
      @settings ||= Settings.get.feature
    end

    def auth_token
      @auth_token ||= request.headers['Auth-Token']
    end

    def authorize!
      raise Constants::UnauthorizedError unless auth_token && current_user
    end

    def authorize_user_or_driver!
      raise Constants::UnauthorizedError unless auth_token && (current_user || current_driver)
    end

    def is_delivery_available?
      render json: {errors: 'Delivery unavailable now'}, status: 422 unless settings.delivery
    end
  end
end
