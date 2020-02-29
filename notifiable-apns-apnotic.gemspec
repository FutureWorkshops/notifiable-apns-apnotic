
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "notifiable/apns/apnotic/version"

Gem::Specification.new do |spec|
  spec.name          = "notifiable-apns-apnotic"
  spec.version       = Notifiable::Apns::Apnotic::VERSION
  spec.authors       = ["Matt Brooke-Smith"]
  spec.email         = ["matt@futureworkshops.com"]

  spec.summary       = 'Apnotic APNS connector for Notifiable'
  spec.homepage      = "https://github.com/FutureWorkshops/notifiable-apns-apnotic"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "notifiable-core", ">= 0.1.3"
  spec.add_dependency 'apnotic', '~> 1.6.0'
  spec.add_dependency 'grocer', '~> 0.7.1'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "database_cleaner"  
  

end
