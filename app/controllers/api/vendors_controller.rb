module Api
  class VendorsController < ApiApplicationController
    before_action :authorize!

    caches_action :show, expires_in: 6.hours

    def index
      res = vendors.as_json(methods: %i(status open_time close_time name_slug))
      render json: res, status: 200
    end

    def show
      render json: vendor.as_json(methods: %i(status open_time close_time name_slug)).merge({ items: items }), status: 200
    end

    private

    def vendors
      @vendors ||= Vendor.visible.order('orders_count DESC')
    end

    def vendor
      @vendor ||= Vendor.find(params[:id])
    end

    def items
      url = URI(vendor.api_url)
      res = Net::HTTP.get(url)
      ActiveSupport::JSON.decode(res)
    end
  end
end
