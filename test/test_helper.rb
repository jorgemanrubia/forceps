# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require 'database_cleaner'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)

DatabaseCleaner[:active_record, connection: :target].strategy = :transaction

class ActiveSupport::TestCase
  setup { DatabaseCleaner[:active_record, connection: :target].start }
  teardown { DatabaseCleaner[:active_record, connection: :target].clean }
end