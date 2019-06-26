ActiveAdmin.register Order do
  actions :index, :show

  controller do
    def permitted_params
      params.permit!
    end
  end
end

