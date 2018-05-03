ActiveAdmin.register User do
  controller do
    def scoped_collection
      User.left_joins(:bonus_trips)
        .select("users.*, COUNT(bonus_trips.id) AS bonus_count")
        .group(:id)
    end

    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    displayed_user_columns.each { |title| column title }
    actions do |user|
      item 'Send Gift', create_gift_admin_user_path(user),
        method: :post, class: 'member_link'
    end
  end

  show do
    attributes_table do
      displayed_user_columns.each { |title| row title }
    end
    render 'custom_actions'
  end

  form do |f|
    semantic_errors
    inputs 'User Details' do
      user_columns.each { |title| input title }
    end
    actions
  end

  member_action :create_gift, method: :post do
    user_id = permitted_params[:id].to_i
    Events::BonusTrips::CreateGift.(user_id: user_id)
    redirect_back fallback_location: admin_user_path(user_id),
      notice: 'Gift successfully sent!'
  end

  remove_filter *Constants::Admin::USER_EXCLUDED_COLUMNS
end

def user_columns
  User.column_names - Constants::Admin::USER_EXCLUDED_COLUMNS
end

def displayed_user_columns
  user_columns + Constants::Admin::USER_MODIFIED_COLUMNS
end
