source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '> 2.4.1'

gem 'rails', '~> 5.2.2'

gem 'actionpack-action_caching'
gem 'activeadmin'
gem 'activeadmin-select2'
gem 'activejob-cancel'
gem 'arctic_admin'
gem 'autoprefixer-rails'
gem 'bcrypt', '~> 3.1.7'
gem 'dry-validation'
gem 'fcm'
gem 'geokit'
gem 'inline_svg'
gem 'jquery-rails'
gem 'multi_json'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'react-rails'
gem 'redis', '~> 3.0'
gem 'roar'
gem 'rollbar'
gem 'sass-rails'
gem 'select2-rails'
gem 'serviceworker-rails'
gem 'sidekiq'
gem 'sitemap_generator'
gem 'slim'
gem 'sprockets'
gem 'telegram-bot'
gem 'turbolinks'
gem 'uglifier'
gem 'wayforpay'
gem 'webpacker'
gem 'websocket-driver', git: 'https://github.com/faye/websocket-driver-ruby', ref: 'ee39af83d03ae3059c775583e4c4b291641257b8'
gem 'whenever', require: false

group :development, :test do
  gem 'letter_opener'
  gem 'pry-rails'
  gem 'reek', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'cuprite'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'simplecov', require: false
  gem 'superbara'
  gem 'webmock'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-db-tasks', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'capistrano-yarn'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
