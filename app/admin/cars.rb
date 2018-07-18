ActiveAdmin.register Car do
  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    semantic_errors
    inputs ' Car Details' do
      (Car.column_names - %w[id]).each do |title|
        input title, as: :string
      end
    end
    actions
  end
end
