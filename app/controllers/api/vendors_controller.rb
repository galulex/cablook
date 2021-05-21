module Api
  class VendorsController < ApiApplicationController
    before_action :authorize!

    def index
      res = vendors.as_json(methods: %i[status open_time close_time name_slug weekends all_day])
      render json: res, status: 200
    end

    def show
      if items
        render json: vendor.as_json(methods: %i[status open_time close_time name_slug all_day]).merge(items: items), status: 200
      else
        render json: { errors: I18n.t('vendors.vendor_unavailable') }.to_json, status: 418
      end
    end

    private

    def vendors
      @vendors ||= Vendor.visible.order(orders_count: :desc)
    end

    def vendor
      @vendor ||= Vendor.find(params[:id])
    end

    def items
      @items = JSON.parse File.open('/home/den/Documents/programming/cablook/public/mcdonalds.json').read
      # @items ||= begin
      #   url = URI(vendor.api_url)
      #   res = Net::HTTP.get(url)
      #   ActiveSupport::JSON.decode(res)
      # rescue StandardError
      #   false
      # end
    end
  end
end
