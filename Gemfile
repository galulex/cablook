source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '> 2.4.1'

gem 'rails', '5.2.8.1'

gem 'actionpack-action_caching'
gem 'activeadmin', '1.4.3'
gem 'activeadmin_addons', '1.10.1'
gem 'activeadmin_json_editor', '0.0.10'
gem 'arctic_admin', '2.1.0'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'bcrypt', '~> 3.1.12', platforms: %i[ruby x64_mingw mingw]
gem 'bcrypt_pbkdf', '1.0'
gem 'bugno', github: 'activebridge/bugno-ruby'
gem 'dry-validation', '1.10'
gem 'ed25519', '1.2.4'
gem 'execjs', '2.7.0'
gem 'fcm', '1.0.8'
gem 'ffi', '1.12.1'
gem 'geokit'
gem 'googleauth', '1.8.0'
gem 'inline_svg'
gem 'multi_json'
gem 'newrelic_rpm'
gem 'nio4r', '2.5.4'
gem 'one_signal'
gem 'paper_trail', '13.0'
gem 'pg'
gem 'pry'
gem 'puma', '6.3.1'
gem 'rack'
gem 'rack-cors'
gem 'react-rails'
gem 'redis', '~> 4.5', '>= 4.5.1'
gem 'rest-client'
gem 'roar'
gem 'sass-rails'
gem 'serviceworker-rails'
gem 'sidekiq', '~> 6.5'
gem 'sitemap_generator'
gem 'slim'
gem 'sprockets'
gem 'telegram-bot'
gem 'turbolinks'
gem 'uglifier'
gem 'wayforpay'
gem 'webpacker', '~> 4.x'
gem 'websocket-driver'
gem 'whenever', require: false

group :development, :test do
  gem 'letter_opener'
  gem 'reek', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '6.2.0'
  gem 'faker', '3.2.1'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-db-tasks', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'capistrano-yarn'
  gem 'listen', '3.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
