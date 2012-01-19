$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#require 'spec'
#require 'spec/autorun'
require 'fakeweb'

require 'gom-script'

Spec::Runner.configure do |config|
  config.before :each do
    FakeWeb.register_uri(
      :get, "http://gom:345/gom/config/connection.txt", 
      :body => "client_ip: 10.0.0.23"
    )
    FakeWeb.register_uri(
      :get, "http://localhost:3000/gom/config/connection.txt", 
      :body => "client_ip: 10.0.0.23"
    )

    Gom::Remote.connection = nil # reset for every test
  end

  config.after :each do
  end
end
