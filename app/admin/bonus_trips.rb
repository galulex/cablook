ActiveAdmin.register BonusTrip do
  BONUS_TRIP_COLUMNS = %w[id user friend trip status type].freeze

  remove_filter :trip, :code, :user
  filter :user_phone_number, as: :string, input_html: { inputmode: :numeric }
  filter :friend_phone_number, as: :string, input_html: { inputmode: :numeric }
  filter :status, as: :select, collection: proc { BonusTrip.statuses }

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :user, :friend)
    end
  end

  index do
    selectable_column
    BONUS_TRIP_COLUMNS.each { |title| column title }
    actions
  end

  show do
    attributes_table do
      BONUS_TRIP_COLUMNS.each { |title| row title }
    end
  end

  form do |f|
    semantic_errors
    inputs do
      f.input :user_id, as: :search_select, url: admin_users_path,
                        fields: [:phone_number], display_name: 'phone_number', minimum_input_length: 2
      f.input :friend_id, as: :search_select, url: admin_users_path,
                          fields: [:phone_number], display_name: 'phone_number', minimum_input_length: 2
      %w[status type].each { |title| input title }
    end
    actions
  end
end
