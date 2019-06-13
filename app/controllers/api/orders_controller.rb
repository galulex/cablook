module Api
  class OrdersController < ApiApplicationController
    before_action :authorize!

    def create
      status = Events::Orders::Create.(order_params.merge(vendor_id: vendor_id))
      render json: status, status: 201
    end

    private

    def order_params
      params.require(:order).permit!.merge(user_id: current_user.id)
    end

    def vendor_id
      Vendor.find_by(name: order_params[:vendor])&.id
    end
  end
end

