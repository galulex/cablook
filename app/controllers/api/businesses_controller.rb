module Api
  class BusinessesController < ApiApplicationController
    def create
      business.update_attributes!(business_params)
      render json: business.to_json(include: %i[users card])
    end
    alias update create

    def show
      raise Constants::NotFoundError if business.new_record?
      render json: business.to_json(include: %i[users card])
    end

    def destroy
      business.destroy!
      render json: business
    end

    private

    def business
      current_user.business || current_user.build_business
    end

    def business_params
      params.require(:business).permit(:name, :email, :card_id, employees: [])
    end
  end
end
