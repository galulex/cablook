ActiveAdmin.setup do |config|
  config.site_title = 'CabLook'

  config.logout_link_path = :destroy_admin_user_session_path
  config.comments = false
  config.batch_actions = true
  config.localize_format = :long
  config.breadcrumb = proc { [] }
end

class ActiveAdmin::BaseController
  http_basic_authenticate_with name: ENV['ADMIN_USERNAME'], password: ENV['ADMIN_PASSWORD']
end
