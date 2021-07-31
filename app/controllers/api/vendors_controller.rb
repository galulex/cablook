module Api
  class VendorsController < ApiApplicationController
    before_action :authorize!

    def index
      res = vendors.as_json(methods: %i[status open_time close_time name_slug weekends all_day])
      render json: res, status: 200
    end

    def show
      if vendor.items
        render json: vendor.as_json(methods: %i[status open_time close_time name_slug all_day]).merge(items: vendor.items), status: 200
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
  end
end
