ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

require 'bcrypt'
require 'capybara/rspec'
require 'rom-rails'
require 'rom-factory'
require 'sidekiq/testing'
require 'simplecov'
require 'webmock/rspec'
require 'rspec/retry'
Dir[
  Rails.root.join('spec/support/**/*.rb'),
  Rails.root.join('lib/constants.rb'),
  Rails.root.join('lib/constants/**/*.rb')
].each { |f| require f }

SimpleCov.start 'rails'

Capybara.javascript_driver = :selenium_chrome

Capybara.register_driver :selenium_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.configure do |config|
  config.default_max_wait_time = 10
  config.default_driver        = :selenium
end

RSpec.configure do |config|
  # config.infer_spec_type_from_file_location!
  # config.filter_rails_from_backtrace!
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

    conn = ROM.env.gateways[:default].connection

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:sequel, connection: conn].strategy = :transaction
    DatabaseCleaner[:sequel, connection: conn].clean_with(:truncation)
  end

  config.around(:each) do |example|
    conn = ROM.env.gateways[:default].connection

    DatabaseCleaner[:sequel, connection: conn].cleaning { example.run }
  end

  config.after(:all, type: :feature) do
    conn = ROM.env.gateways[:default].connection
    DatabaseCleaner[:sequel, connection: conn].clean_with(:truncation)
  end

  config.before(:each, type: :feature) do
    WebMock.disable_net_connect! allow_localhost: true
    Capybara.current_session.driver.browser.manage.window.resize_to(960, 640)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start

    body = File.read('spec/fixtures/maps/success_directions')
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/directions\/.*/)
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: body)
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  Factory = ROM::Factory.configure do |config|
    config.rom = ROM.env
  end
  Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }
  ActiveJob::Base.queue_adapter = :test
end
