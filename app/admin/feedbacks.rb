ActiveAdmin.register Feedback do
  remove_filter :trip

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip, :user, :driver)
    end
  end

  index do
    selectable_column
    feedback_columns.each { |title| column title }
    column :driver do |feedback|
      feedback_driver_link(feedback)
    end
    actions
  end

  show do
    attributes_table do
      feedback_columns.each { |title| row title }
      row :driver do |feedback|
        feedback_driver_link(feedback)
      end
    end
  end

  form do |f|
    inputs do
      %w[rate description].each { |title| input title }
    end
    actions
  end

  filter :driver
  preserve_default_filters!
end

def feedback_columns
  columns_exclude = %w[user_id trip_id]
  added_columns = %w[trip user]
  Feedback.column_names - columns_exclude + added_columns
end

def feedback_driver_link(feedback)
  link_to feedback.driver.username, admin_driver_path(feedback.driver) if feedback.driver
end
