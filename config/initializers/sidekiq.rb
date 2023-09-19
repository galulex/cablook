require 'sidekiq/web'

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'], size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'], size: 7 }
  end
end

Sidekiq::Web.use Rack::Auth::Basic, 'Protected Area' do |username, password|
  Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'] || Rails.application.secrets[:sidekiq_username])) &
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'] || Rails.application.secrets[:sidekiq_password]))
end
