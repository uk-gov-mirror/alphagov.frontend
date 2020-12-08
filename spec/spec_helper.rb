require "byebug"
require "simplecov"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "capybara/rspec"
require "webmock/rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
SimpleCov.start

RSpec.configure do |config|
  config.render_views
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include Capybara::RSpecMatchers, type: :request
end
