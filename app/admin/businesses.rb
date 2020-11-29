ActiveAdmin.register Business do
  remove_filter :owner, :card

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    semantic_errors
    inputs do
      f.input :user_id, label: 'Owner', as: :search_select, url: admin_owners_path,
                        fields: [:phone_number], display_name: 'phone_number', minimum_input_length: 2
      f.input :card, label: 'Card', as: :select, collection: Card.all.map { |c| [c.pan, c.id] }
      %w[name email].each { |title| input title }
    end
    actions
  end
end
