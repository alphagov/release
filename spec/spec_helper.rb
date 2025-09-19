ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require "simplecov"
SimpleCov.start "rails"

require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"
require "artemis/rspec"
require "capybara/rails"
require "selenium-webdriver"
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

# Capybara.register_driver :headless_chrome do |app|
#   options = GovukTest.headless_chrome_selenium_options
#     Config tried
#     options.add_argument("--headless=new") # already configured by GovukTest.configure 
#     options.add_argument("--no-sandbox")   # already configured by GovukTest.configure 
#     options.add_argument("--headless")
#     options.add_argument("--disable-gpu")
#     options.add_argument("--disable-dev-shm-usage")  # Recommended for Docker
#     options.add_argument("user-data-dir=#{Dir.mktmpdir}")  # Create a unique temp dir for each session
#     options.delete_argument("--user-data-dir") # Delete the argument

#     # Enable loggingr
#     options.add_argument("--remote-debugging-port=9222") # Enable remote debugging
#     options.add_argument("--enable-logging")
#     options.add_argument("--v=1") # Set the verbosity level to 1 (info level)

#   Capybara::Selenium::Driver.new(
#     app,
#     browser: :chrome,
#     desired_capabilities: { acceptInsecureCerts: true },
#     options: options,
#   )
# end


WebMock.disable_net_connect!(allow_localhost: true)
Rails.application.load_tasks

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
    # Also tried
    # Capybara.reset_sessions!
    # Capybara.use_default_driver
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # will default to `true` in RSpec 4.
  end

  config.include AuthenticationHelper, type: :request
  config.include Capybara::RSpecMatchers, type: :request

  config.fixture_paths = [Rails.root.join("spec/fixtures")]
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end
