ActiveAdmin.register User do
  controller do
    def permitted_params
      params.permit!
    end
  end
end
