ActiveAdmin.register User, as: 'Owner' do
  controller do
    def scoped_collection
      super.joins(:cards)
    end
  end
end
