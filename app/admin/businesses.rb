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
      f.input :card_id, as: :nested_select,
                        level_1: {
                          display_name: :phone_number,
                          fields: [:phone_number],
                          attribute: :user_id,
                          minimum_input_length: 2,
                          url: '/admin/owners' },
                        level_2: {
                          display_name: :pan,
                          fields: [:pan],
                          attribute: :card_id,
                          minimum_input_length: 0,
                          url: '/admin/cards' }
      %w[name email].each { |title| input title }
    end
    actions
  end
end
