require "bundler/setup"
require "notifiable/apns/apnotic"
require "factory_bot"
require "byebug"
require "database_cleaner"

# Load support dir
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Setup ActiveRecord db connection
ActiveRecord::Base.establish_connection(YAML.load_file('config/database.yml')['test'])

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  
  # Remove the need for RSpec prefixes
  config.expose_dsl_globally = true
  
  # Remove need for factory girl prefix
  config.include FactoryBot::Syntax::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  config.before(:all) {
    DatabaseCleaner.strategy = :truncation
  }

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
