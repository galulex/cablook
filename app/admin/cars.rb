ActiveAdmin.register Car do
  remove_filter :trips

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    semantic_errors
    inputs 'Car Details' do
      input :number
      input :status
      input :color, as: :select, collection: Constants::Car::COLORS
      input :phone_number
      input :active, as: :select
    end
    actions
  end
end
