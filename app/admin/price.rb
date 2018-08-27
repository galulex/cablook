ActiveAdmin.register Price do
  config.filters = false
  config.batch_actions = false
  actions :all, except: %i[new show destroy]
  
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do |f|
    %i[cents_per_km outside_cents_per_km landing fake idle_price min_price coefficient].each { |title| column title }
    actions
  end

  form do |f|
    inputs 'Price' do
      input :cents_per_km,         step: 50
      input :outside_cents_per_km, step: 50
      input :landing,              step: 50 
      input :fake
      input :idle_price
      input :min_price,            step: 50
      input :coefficient,          step: 0.1
    end
    actions
  end
end