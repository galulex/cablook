source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '3.2.2'

gem 'rails', '7.0.8'

gem 'actionpack-action_caching'
gem 'activeadmin', '3.0.0'
gem 'activeadmin_addons', '1.10.1'
gem 'activeadmin_json_editor', '0.0.10'
gem 'arctic_admin', '4.2.5'
gem 'autoprefixer-rails', '10.4.15.0'
gem 'awesome_print', '1.9.2'
gem 'bcrypt', '~> 3.1.12', platforms: %i[ruby x64_mingw mingw]
gem 'bcrypt_pbkdf', '1.0'
gem 'bugno', github: 'activebridge/bugno-ruby'
gem 'dry-validation', '1.10'
gem 'ed25519', '1.2.4'
gem 'execjs', '2.9.1'
gem 'fcm', '1.0.8'
gem 'ffi', '1.12.1'
gem 'geokit', '1.14'
gem 'googleauth', '1.8.0'
gem 'inline_svg', '1.9.0'
gem 'multi_json'
gem 'newrelic_rpm'
gem 'nio4r', '2.5.8'
gem 'one_signal'
gem 'paper_trail', '15.0'
gem 'pg', '1.5.4'
gem 'pry'
gem 'psych', '< 4'
gem 'puma', '6.3.1'
gem 'rack', '2.2.8'
gem 'rack-cors', '2.0.1'
gem 'react-rails', '3.1.1'
gem 'redis', '5.0.7'
gem 'rest-client', '2.1'
gem 'roar', '1.2'
gem 'sass-rails', '6.0.0'
gem 'serviceworker-rails', '0.6.0'
gem 'sidekiq', '7.1.4'
gem 'sitemap_generator', '6.3'
gem 'slim', '5.1.1'
gem 'sprockets', '4.2.1'
gem 'telegram-bot', '0.15.7'
gem 'turbolinks', '5.2.1'
gem 'uglifier', '4.2.0'
gem 'wayforpay'
gem 'webpacker', '5.4.4'
gem 'websocket-driver', '0.7.6'
gem 'whenever', require: false

group :development, :test do
  gem 'letter_opener'
  gem 'reek', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara', '3.39.2'
  gem 'cuprite', '0.14.3'
  gem 'database_cleaner', '2.0.2'
  gem 'factory_bot_rails', '6.2.0'
  gem 'faker', '3.2.1'
  gem 'rspec-rails', '6.0.3'
  gem 'rspec-retry', '0.6.2'
  gem 'simplecov', require: false
  gem 'webmock', '3.19.1'
end

group :development do
  gem 'capistrano', '3.17.3'
  gem 'capistrano-db-tasks', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'capistrano-yarn'
  gem 'listen', '3.5'
  gem 'spring', '4.1.1'
  gem 'spring-watcher-listen', '2.1'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
