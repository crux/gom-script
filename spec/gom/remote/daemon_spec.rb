require File.dirname(__FILE__)+'/../../spec_helper'

include Gom::Remote

describe Gom::Remote::Daemon do

  describe "with a plain vanilla daemon" do
    before :each do
      @daemon = Daemon.new 'http://gom:345/gom-script/test'
    end
    it "should parse the service_path from the service_url" do
      @daemon.service_path.should == '/gom-script/test'
    end
    it "should terminate sensor loop on :stop" do
      count = 0
      timeout(1) do
        @daemon.sensor_loop(0.1) { count += 1; :stop if count == 3 }
      end
      count.should == 3
    end
    it "should terminate actor loop on :stop" do
      Gom::Remote.connection.should_receive(:refresh)
      timeout(1) { @daemon.actor_loop { :stop } }
    end
  end

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
  end
end
