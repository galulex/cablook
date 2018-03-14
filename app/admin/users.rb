ActiveAdmin.register User do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    user_columns.each { |title| column title }
    actions
  end

  show do
    attributes_table do
      user_columns.each { |title| row title }
    end
  end

  form do |f|
    semantic_errors
    inputs ' User Details' do
      user_columns.each { |title| input title }
    end
    actions
  end

  remove_filter :encrypted_password, :auth_token, :confirmation_token, :verification_token
end

def user_columns
  columns_exclude = %w[encrypted_password auth_token confirmation_token verification_token]
  User.column_names - columns_exclude
end
