module Api
  class DeliveryController < ApiApplicationController
    before_action :authorize!

    def new
      trip = Events::Orders::Build.(trip_params)
      render json: Presenters::Trips::Single.new(trip).to_json, status: 200
    end

    def create
      trip = Events::Delivery::Create.(order_params)
      render json: trip, status: 201
    end

    private

    def order_params
      params.require(:order).permit!.merge(user_id: current_user.id)
    end

    def trip_params
      params.permit(:destination, :destination_address, :vendor_id)
    end
  end
end
