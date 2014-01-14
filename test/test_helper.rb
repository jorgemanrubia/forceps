# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require 'database_cleaner'
require 'database_cleaner/active_record/base'
require 'awesome_print'
require 'minitest/reporters'

MiniTest::Reporters.use!

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)


DatabaseCleaner::ActiveRecord.config_file_location = File.expand_path("../dummy/config/database.yml", __FILE__)

DatabaseCleaner.strategy = :truncation
DatabaseCleaner[:active_record, connection: :remote].strategy = :truncation

class ActiveSupport::TestCase
  setup do
    DatabaseCleaner.start
    DatabaseCleaner[:active_record, connection: :remote].start
  end
  teardown do
    DatabaseCleaner.clean
    DatabaseCleaner[:active_record, connection: :remote].clean
  end
end