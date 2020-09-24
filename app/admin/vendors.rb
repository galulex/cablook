ActiveAdmin.register Vendor do
  preserve_default_filters!

  before_action :clean_weekends, only: [:update, :create]

  controller do
    def permitted_params
      params.permit!
    end

    def clean_weekends
      permitted_params[:vendor][:weekends].reject!(&:blank?)
    end
  end

  form do |f|
    semantic_errors
    f.input :name
    f.input :description, as: :text
    f.input :location
    f.input :address
    f.input :url
    f.input :api_url
    f.input :logo_url
    f.input :telegram_account
    f.input :phone_number
    f.input :open_at, as: :time_picker
    f.input :close_at, as: :time_picker
    f.input :active, as: :boolean
    f.input :need_approve, as: :boolean
    f.input :weekends, as: :check_boxes, collection: Date::DAYNAMES
    actions
  end
end
