module Api
  class AddressesController < ApiApplicationController
    before_action :authorize!

    def show
      render json: { address: ReverseGeocoding.new(params[:coords]).address }
    end
  end
end
