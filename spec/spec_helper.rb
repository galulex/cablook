ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

require 'bcrypt'
require 'rom-rails'
require 'rom-factory'
require 'sidekiq/testing'
require 'simplecov'
require 'webmock/rspec'
Dir[
  Rails.root.join('spec/support/**/*.rb'),
  Rails.root.join('lib/constants.rb'),
  Rails.root.join('lib/constants/**/*.rb')
].each { |f| require f }

SimpleCov.start

RSpec.configure do |config|
  # config.infer_spec_type_from_file_location!
  # config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do

    conn = ROM.env.gateways[:default].connection

    DatabaseCleaner[:sequel, connection: conn].strategy = :transaction
    DatabaseCleaner[:sequel, connection: conn].clean_with(:truncation)
  end

  config.around(:each) do |example|
    conn = ROM.env.gateways[:default].connection

    DatabaseCleaner[:sequel, connection: conn].cleaning { example.run }
  end

  config.before(:each) do
    body = File.read('spec/fixtures/maps/success_directions')
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/directions\/.*/)
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: body)
  end

  Factory = ROM::Factory.configure do |config|
    config.rom = ROM.env
  end
  Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }
  ActiveJob::Base.queue_adapter = :test
end
