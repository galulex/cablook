ActiveAdmin.register Vendor do
  preserve_default_filters!

  controller do
    def permitted_params
      params.permit!
    end
  end
end
