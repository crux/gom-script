# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'fakeweb'

require 'gom/remote'

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
