require 'sidekiq/web'

if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDISTOGO_URL'], size: 5 }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISTOGO_URL'], size: 1 }
  end
end

Sidekiq::Web.set :session_secret, ENV['SECRET_KEY_BASE']

Sidekiq::Web.use Rack::Auth::Basic, 'Protected Area' do |username, password|
  Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])) &
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
end
