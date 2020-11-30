ActiveAdmin.register User, as: 'Owner' do
  actions :index
  menu false
  permit_params :phone_number

  controller do
    def scoped_collection
      super.joins(:cards)
    end
  end
end
