ActiveAdmin.register Order do
  preserve_default_filters!
  remove_filter :trip, :payment

  filter :trip_status, as: :select, collection: proc { Trip.statuses }

  actions :index, :show

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :user)
    end
  end
end
