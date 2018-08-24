require "bundler/setup"
require "notifiable/apns/apnotic"

# Setup ActiveRecord
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'db/test.sqlite3')
ActiveRecord::Migration.verbose = false
notifiable_rails_path = Gem.loaded_specs['notifiable-rails'].full_gem_path
ActiveRecord::MigrationContext.new(File.join(notifiable_rails_path, 'db', 'migrate')).migrate

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
