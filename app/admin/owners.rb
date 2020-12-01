ActiveAdmin.register User, as: 'Owner' do
  actions :index
  menu false
  permit_params :phone_number

  controller do
    def scoped_collection
      super.joins(:cards).select("distinct on (phone_number) cards.user_id, cards.created_at, users.*").order("user_id, cards.created_at")
    end
  end
end
