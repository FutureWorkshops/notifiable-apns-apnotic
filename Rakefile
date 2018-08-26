require "bundler/gem_tasks"
require "rspec/core/rake_task"

notifiable_path = Gem::Specification.find_by_name 'notifiable-core'
load "#{notifiable_path.gem_dir}/lib/tasks/db.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
