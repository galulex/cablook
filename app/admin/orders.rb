ActiveAdmin.register Order do
  preserve_default_filters!
  remove_filter :trip, :payment
  actions :index, :show

  controller do
    def permitted_params
      params.permit!
    end
  end
end

