require File.dirname(__FILE__)+'/../../spec_helper'

include Gom::Remote

describe Gom::Remote::Daemon do

  describe "initialization" do

    it "should find the class" do
      Daemon.should_not == nil
    end

    it "should init the connection" do
      Gom::Remote.connection.should == nil
      Daemon.new 'http://gom:345/gom-script/test'
      (c = Gom::Remote.connection).should_not == nil
      c.target_url.should == 'http://gom:345'
      c.initial_path.should == '/gom-script/test'
      c.callback_server.port.should == Daemon::Defaults[:callback_port]
    end

    #it "should split a GOM node url" do
    #  gom, path = (Gom::Remote::Connection.split_url 'http://gom:345/dmx/node')
    #  gom.should == 'http://gom:345'
    #  path.should == '/dmx/node'
    #end
  end
end
