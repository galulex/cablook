source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'

gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'

gem 'rom-rails'
gem 'rom-repository'
gem 'rom-sql'
gem 'dry-validation'
gem 'bcrypt', '~> 3.1.7'
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'rom-factory'
  gem 'pry-rails'
  gem 'reek', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
