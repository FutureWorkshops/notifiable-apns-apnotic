require "bundler/setup"
require "notifiable/apns/apnotic"

# Setup ActiveRecord db connection
ActiveRecord::Base.establish_connection(YAML.load_file('config/database.yml')['test'])

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  
  # Remove the need for RSpec prefixes
  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
