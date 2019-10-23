ActiveAdmin.register User do
  remove_filter :trips, :business, :bussinesses, :cards, :bonus_trips, :favorite_addresses,
                :parent_bonus, :orders, :referral_code, :notification_settings

  controller do
    def scoped_collection
      super.left_joins(:bonus_trips)
        .select("users.*, COUNT(bonus_trips.id) AS bonus_count")
        .group(:id)
    end

    def permitted_params
      params.permit!
    end

    def notify_all_about_unpaid_trip
      users_ids = Trip.all.unpaid.pluck(:user_id).uniq
      Jobs::NotifyUsers.perform_later(users_ids)
      redirect_to collection_path, notice: 'Notifications successfully sent!'
    end
  end

  index do
    selectable_column
    displayed_user_columns.each { |title| column title }
    column(:trips) { |user| link_to 'trips', admin_trips_path(q: { user_id_eq: user.id }) }
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
    inputs do
      %w[email phone_number referral_code vip].each { |title| input title }
    end
    actions
  end

  action_item(:notify) { link_to 'Notify all users about UNPAID trip', notify_admin_users_path, method: :post }

  collection_action :notify, method: :post do
    notify_all_about_unpaid_trip
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
