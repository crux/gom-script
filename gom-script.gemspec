# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'gom/script/version'

Gem::Specification.new do |s|
  s.name        = 'gom-script'
  s.version     = Gom::Script::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['art+com/dirk luesebrink']
  s.email       = ['dirk.luesebrink@artcom.de']
  s.homepage    = 'http://github.com/crux/gom-script'
  s.summary     = 'connecting scripts and daemons with a remote GOM instance'
  s.description = %q{ 
    gom-script script simplifies coding of clients and daemon which like to
    listen on state change event in the GOM.
  }

  s.add_dependency 'json'
  s.add_dependency 'rack'
  s.add_dependency 'mongrel', '>=1.2.0.pre2'
  s.add_dependency 'applix' # for OAttr in http_server
  s.add_dependency 'gom-core'

  # development section
  #
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'growl'
  if RUBY_PLATFORM.match /java/i
    s.add_development_dependency 'ruby-debug'
  else
    s.add_development_dependency 'debugger'
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f| 
    File.basename(f)
  end
  s.require_paths = ["lib"]
end
