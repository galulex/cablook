ActiveAdmin.register Business do
  remove_filter :owner, :card, :users

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    semantic_errors
    inputs do
      f.input :user_id, label: 'Owner', as: :select2, collection: User.all.map { |u| [u.phone_number, u.id] }
      f.input :card, label: 'Card', as: :select2, collection: Card.all.map { |c| [c.pan, c.id] }
      %w[name email].each { |title| input title }
    end
    actions
  end
end
