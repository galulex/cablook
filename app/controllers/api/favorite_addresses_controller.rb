module Api
  class FavoriteAddressesController < ApiApplicationController
    before_action :authorize!

    def index
      render json: { favorite_addresses: favorite_addresses }, status: 200
    end

    def create
      favorite_address = Events::FavoriteAddresses::Create.(params.merge(user_id: current_user.id))
      favorite_address ? (render json: favorite_address, status: :created) : (status :unprocessable_entity)
    end

    def destroy
      event = Events::FavoriteAddresses::Delete.(id: params[:id].to_i, user_id: current_user.id)
      raise Constants::NotFoundError unless event
      head :ok
    end

    private

    def favorite_addresses
      @favorite_addresses ||= current_user.favorite_addresses
    end

    def favorite_address_params
      params.permit(:name, :location, :user_id)
    end
  end
end
