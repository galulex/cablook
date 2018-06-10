ActiveAdmin.register Tip do
  remove_filter :trip

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    %w[id amount trip user driver card_pan response].each { |title| column title }
    actions
  end
end
