ActiveAdmin.register User do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    user_columns
    actions
  end

  remove_filter :encrypted_password, :auth_token, :confirmation_token, :verification_token
end

def user_columns
  columns_exclude = %w[encrypted_password auth_token confirmation_token verification_token]
  (User.column_names - columns_exclude).each do |title|
    column title
  end
end
