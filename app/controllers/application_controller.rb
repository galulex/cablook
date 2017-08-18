class ApplicationController < ActionController::API
  rescue_from Events::InvalidParamsError do |errors|
    render json: { errors: JSON.parse(errors.message) }, status: 400
  end
end
