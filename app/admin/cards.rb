ActiveAdmin.register Card do
  actions :index
  menu false
  permit_params :pan, :user_id

  controller do
    def scoped_collection
      super.order(created_at: :desc)
    end
  end
end
