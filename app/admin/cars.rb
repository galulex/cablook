ActiveAdmin.register Car do
  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    semantic_errors
    inputs ' Car Details' do
      input :number
      input :status
      input :color, as: :string
      input :phone_number
    end
    actions
  end
end
