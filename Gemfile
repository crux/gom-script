source :rubygems

# Specify your gem's dependencies in gom-script.gemspec
gemspec

gem 'json'
gem 'rack'
gem 'mongrel', '>=1.2.0.pre2'
gem 'applix'
gem 'gom-core'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
    gem 'wirble'
    gem 'rspec'
    gem 'fakeweb', '>= 1.2.7'

    gem 'ruby-debug', :platforms => :mri_18
    gem 'ruby-debug19', :platforms => :mri_19, :require => 'ruby-debug'
    gem 'ruby-debug-base19', :platforms => :mri_19
end
