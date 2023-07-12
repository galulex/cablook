source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '> 2.4.1'

gem 'rails', '~> 5.2.7'

gem 'actionpack-action_caching'
gem 'activeadmin'
gem 'activeadmin_addons'
gem 'activeadmin_json_editor', '~> 0.0.7'
gem 'arctic_admin'
gem 'autoprefixer-rails'
gem 'awesome_print'
gem 'bcrypt', '~> 3.1.12'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
gem 'bugno', github: 'activebridge/bugno-ruby'
gem 'dry-validation'
gem 'ed25519'
gem 'execjs', '2.7.0'
gem 'fcm'
gem 'geokit'
gem 'googleauth', '~> 0.15.0'
gem 'inline_svg'
gem 'jquery-rails'
gem 'multi_json'
gem 'newrelic_rpm'
gem 'one_signal'
gem 'paper_trail'
gem 'pg', '~> 0.18'
gem 'pry'
gem 'puma', '~> 5.6', '>= 5.6.5'
gem 'rack'
gem 'rack-cors'
gem 'react-rails'
gem 'redis', '~> 3.0'
gem 'rest-client'
gem 'roar'
gem 'sass-rails'
gem 'serviceworker-rails'
gem 'sidekiq'
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
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker'
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
