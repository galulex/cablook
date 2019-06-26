ActiveAdmin.register Vendor do
  controller do
    def permitted_params
      params.permit!
    end
  end
end
