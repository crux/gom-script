require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see
    # http://www.rubygems.org/read/chapter/20 for additional settings
    #
    gem.name = "gom-script"
    gem.summary = %Q{connecting scripts and daemons with a remote GOM instance}
    gem.description = %Q{ 
      GOM is a schema-less object database in ruby with Resource Oriented API,
      server-side javascript, distributed HTTP notifications and some more.
      This gom-script script simplifies coding of clients and daemon which like
      to listen on state change event in the GOM.
    }.gsub /\n\n/, ''
    gem.email = "dirk.luesebrink@gmail.com"
    gem.homepage = "http://github.com/crux/gom-script"
    gem.authors = ["art+com/dirk luesebrink"]
    gem.add_runtime_dependency "json"
    gem.add_runtime_dependency "rack"
    gem.add_runtime_dependency "mongrel"
    gem.add_runtime_dependency "applix", ">=0.2.1"
    gem.add_runtime_dependency "gom-core"

    gem.add_development_dependency "rspec"
    gem.add_development_dependency "fakeweb", ">=1.2.7"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-c)
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'spec/**/*_spec.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "GOM Remote - #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :test => :check_dependencies
task :default => :spec
