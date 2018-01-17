source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'

gem 'activeadmin'
gem 'activejob-cancel'
gem 'bcrypt', '~> 3.1.7'
gem 'coffee-rails'
gem 'dry-validation'
gem 'google_distance_matrix'
gem 'inline_svg'
gem 'multi_json'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'redis', '~> 3.0'
gem 'roar'
gem 'rom-model'
gem 'rom-rails'
gem 'rom-repository'
gem 'rom-sql'
gem 'sass-rails'
gem 'sidekiq'
gem 'slim'
gem 'turbolinks'
gem 'twilio-ruby', '~> 5.2.1'
gem 'uglifier'
gem 'wayforpay'

group :development, :test do
  gem 'github_workflow'
  gem 'pry-rails'
  gem 'reek', require: false
  gem 'rom-factory'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
