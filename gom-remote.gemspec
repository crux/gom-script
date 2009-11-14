# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gom-remote}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["art+com/dirk luesebrink"]
  s.date = %q{2009-11-14}
  s.description = %q{ 
      GOM is a schema-less object database in ruby with Resource Oriented API,
      server-side javascript, HTTP callbacks and some more. This gom-remote
      script simplifies coding of clients and daemon which like to listen on
      state change event in the GOM.
    }
  s.email = %q{dirk.luesebrink@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "gom-remote.gemspec",
     "lib/gom/remote.rb",
     "lib/gom/remote/callback_server.rb",
     "lib/gom/remote/connection.rb",
     "lib/gom/remote/daemon.rb",
     "lib/gom/remote/entry.rb",
     "lib/gom/remote/subscription.rb",
     "spec/gom/remote/callback_server_spec.rb",
     "spec/gom/remote/connection_spec.rb",
     "spec/gom/remote/subscription_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/crux/gom-remote}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{connecting scripts and daemons with a remote GOM instance}
  s.test_files = [
    "spec/gom/remote/callback_server_spec.rb",
     "spec/gom/remote/connection_spec.rb",
     "spec/gom/remote/subscription_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
