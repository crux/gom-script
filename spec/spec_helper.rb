$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'gom/remote'

Spec::Runner.configure do |config|
  config.before :each do
    #@gom = stub('Gom::Remote::Connection', :write => nil)
    #(Gom::Remote::Connection.stub! :new).and_return @gom
  end

  config.after :each do
  end
end
