ActiveAdmin.register User do
  remove_filter :trips, :business, :bussinesses, :cards, :bonus_trips, :favorite_addresses,
                :parent_bonus, :orders, :referral_code, :notification_settings, :versions, :devices, :telegram, :locale, :cashback
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
      Jobs::NotifyUsers.perform_later
      redis.set("button_state", true)
      redirect_to collection_path, notice: 'Notifications successfully sent!'
    end

    def redis
      @redis ||= Redis.current
    end

    def index
      @button_blocked = redis.get('button_state')
      index!
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
      f.input :locale, as: :select, collection: I18n.config.available_locales
      f.input :business_ids, as: :select, label: 'Business', collection: Business.all.map { |b| [b.name, b.id] }
    end
    actions
  end

  action_item(:notify) { button_to 'Notify all users about UNPAID trip', notify_admin_users_path, disabled: controller.instance_variable_get(:@button_blocked) == 'true' }

  collection_action :notify, method: :post do
    notify_all_about_unpaid_trip
  end

  member_action :create_gift, method: :post do
    user_id = permitted_params[:id].to_i
    Events::BonusTrips::CreateGift.(user_id: user_id) if settings.bonuses
    redirect_back fallback_location: admin_user_path(user_id),
      notice: settings.bonuses ? 'Gift successfully sent!' : 'Gifts disabled now!'
  end

  remove_filter *Constants::Admin::USER_EXCLUDED_COLUMNS
end

def user_columns
  User.column_names - Constants::Admin::USER_EXCLUDED_COLUMNS
end

def displayed_user_columns
  user_columns + Constants::Admin::USER_MODIFIED_COLUMNS
end

def settings
  @settings ||= Settings
end
