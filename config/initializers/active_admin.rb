ActiveAdmin.setup do |config|
  config.site_title = 'CabLook'

  config.logout_link_path = :destroy_admin_user_session_path
  config.comments = false
  config.batch_actions = true
  config.localize_format = :long
  config.breadcrumb = proc { [] }
  config.before_action :set_admin_locale
  meta_tags_options = { viewport: 'width=device-width, initial-scale=1' }
  config.meta_tags = meta_tags_options
  config.meta_tags_for_logged_out_pages = meta_tags_options
end

class ActiveAdmin::BaseController
  http_basic_authenticate_with name: ENV['ADMIN_USERNAME'], password: ENV['ADMIN_PASSWORD']
end
