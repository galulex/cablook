ActiveAdmin.register Business do
  remove_filter :owner, :card, :users

  controller do
    def permitted_params
      params.permit!
    end
  end
end
