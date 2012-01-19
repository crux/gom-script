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
  #s.rubyforge_project = "gom-core"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f| 
    File.basename(f)
  end
  s.require_paths = ["lib"]
end
