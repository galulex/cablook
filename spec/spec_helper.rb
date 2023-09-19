ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'bcrypt'
require 'capybara/rails'
require 'capybara/cuprite'
require 'capybara/rspec'
require 'sidekiq/testing'
require 'webmock/rspec'
require 'rspec/retry'
require 'support/factory_bot'

Dir[
  Rails.root.join('lib/constants.rb'),
  Rails.root.join('lib/constants/**/*.rb'),
  Rails.root.join('spec/support/**/*.rb')
].each { |f| require f }

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, browser_options: { 'no-sandbox': nil, 'enable-auto-reload': nil }, process_timeout: 30, timeout: 15)
end

Capybara.javascript_driver = :cuprite

RSpec.configure do |config|
  config.verbose_retry = true

  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    WebMock.disable_net_connect! allow_localhost: true
    body = File.read('spec/fixtures/maps/success_directions')
    body_mapbox = File.read('spec/fixtures/maps/mapbox_success_directions')
    card_verify_success_response = File.read('spec/fixtures/fondy/card_verify_success_response.json')
    stub_request(:get, %r{https://maps.googleapis.com/maps/api/directions/.*})
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: body)
    stub_request(:get, %r{https://osrm.cablook.taxi/route/v1/driving/.*})
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: body_mapbox)
    stub_request(:post, %r{https://pay.fondy.eu/api/})
      .to_return(status: 200, body: card_verify_success_response, headers: {})
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    unless driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
    Settings.create
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  # Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }
  ActiveJob::Base.queue_adapter = :test
  Capybara.default_host = 'http://app.lvh.me'
  Capybara.server_port = 9887
  Capybara.app_host = "http://app.lvh.me:#{Capybara.server_port}"
end
