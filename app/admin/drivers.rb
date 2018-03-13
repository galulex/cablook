ActiveAdmin.register Driver do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column :id
    column :name
    column :username
    column :car
    column :phone_number
    actions
  end

  remove_filter :encrypted_password, :auth_token
end
