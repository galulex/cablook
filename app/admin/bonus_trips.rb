ActiveAdmin.register BonusTrip do
  BONUS_TRIP_COLUMNS = %w[id user friend trip status type].freeze

  preserve_default_filters!
  remove_filter :trip, :code
  filter :user,   as: :select, collection: proc { User.joins(:bonus_trips).group(:id).all }
  filter :friend, as: :select, collection: proc { User.select(User.arel_table[Arel.star]).where(BonusTrip.arel_table[:friend_id].not_eq(nil)).joins(User.arel_table.join(BonusTrip.arel_table).on(BonusTrip.arel_table[:friend_id].eq(User.arel_table[:id])).join_sources).group(:id) }

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
      %w[user friend status type].each { |title| input title }
    end
    actions
  end
end