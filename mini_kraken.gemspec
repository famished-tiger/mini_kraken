lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mini_kraken/version"

# Implementation module
module PkgExtending
  def self.pkg_files(aPackage)
    file_list = Dir[
      '.rspec',
      '.travis.yml',
      'Gemfile',
      'Rakefile',
      'CHANGELOG.md',      
      'LICENSE.txt',
      'README.md',
      'mini_kraken.gemspec',
      'bin/*.rb',
      'lib/*.*',
      'lib/**/*.rb',
      'spec/**/*.rb'
    ]
    aPackage.files = file_list
    aPackage.test_files = Dir['spec/**/*_spec.rb']
    aPackage.require_path = 'lib'
  end

  def self.pkg_documentation(aPackage)
    aPackage.rdoc_options << '--charset=UTF-8 --exclude="examples|spec"'
    aPackage.extra_rdoc_files = ['README.md']
  end
end # module

Gem::Specification.new do |spec|
  spec.name          = "mini_kraken"
  spec.version       = MiniKraken::VERSION
  spec.authors       = ['Dimitri Geshef']
  spec.email         = ['famished.tiger@yahoo.com']

  spec.summary       = %q{Implementation of Minikanren language in Ruby. WIP}
  spec.description   = %q{Implementation of Minikanren language in Ruby. WIP}
  spec.homepage      = "https://github.com/famished-tiger/mini_kraken"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  PkgExtending.pkg_files(spec)
  PkgExtending.pkg_documentation(spec)  

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
