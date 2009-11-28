$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'fakeweb'

require 'gom/remote'

Spec::Runner.configure do |config|
  config.before :each do
    FakeWeb.register_uri(
      :get, "http://gom:345/gom/config/connection.txt", :body => "client_ip: 10.0.0.23"
    )
    #@gom = stub('Gom::Remote::Connection', :write => nil)
    #(Gom::Remote::Connection.stub! :new).and_return @gom
  end

  config.after :each do
  end
end
