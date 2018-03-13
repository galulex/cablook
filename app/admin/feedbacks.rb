ActiveAdmin.register Feedback do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column :id
    column :rate
    column :description
    column :trip
    column :driver do |feedback|
      link_to feedback.driver.username, admin_driver_path(feedback.driver)
    end
    column :user
    actions
  end

  filter :driver
  preserve_default_filters!
end
