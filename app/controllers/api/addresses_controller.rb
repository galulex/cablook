module Api
  class AddressesController < ApiApplicationController
    before_action :authorize!

    def show
      render json: { address: Yandex.new(params[:coords]).address }
    end
  end
end
